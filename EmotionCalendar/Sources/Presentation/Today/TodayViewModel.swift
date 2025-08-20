//
//  TodayViewModel.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/20/25.
//

import Foundation
import SwiftUI
import SwiftData
import HealthKit
import Observation

@Observable
class TodayViewModel {
    var events: [EventModel] = []
    var selectedEvent: EventModel? = nil // 로깅 시트용
    var detailLog: MoodLog? = nil // 상세 시트용
    var errorMsg: String?
    var saving = false
    var dailyScore: Int = 0
    var todayInterval: DateInterval {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    private(set) var todayLogs: [MoodLog] = []
    private let ek = EventKitFetcher()
    private let hkStore: HKHealthStore
    private let somManager: StateOfMindManager
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        self.hkStore = HKHealthStore()
        self.somManager = StateOfMindManager(store: self.hkStore)
    }

    func updateLogs(_ logs: [MoodLog]) {
        self.todayLogs = logs
    }

    var logsById: [String: MoodLog] {
        Dictionary(uniqueKeysWithValues: todayLogs.map { ($0.eventId, $0) })
    }

    func loadToday() async {
        do {
            try await ek.requestAccess()
            events = ek.fetchToday()
            dailyScore = somManager.dailyWorkShareByDuration(for: Date(), events: events, logs: todayLogs)
        } catch {
            errorMsg = error.localizedDescription
        }
    }

    @MainActor
    func logEvent(event: EventModel, emoji: EmojiType, note: String?) async {
        saving = true; defer { saving = false }
        // 1) HealthKit 저장
        await saveSelection(event: event, emoji: emoji)
        // 2) SwiftData 저장
        do {
            try upsertLog(event: event, emoji: emoji, note: note)
            // 3) 게이지 갱신
            dailyScore = somManager.dailyWorkShareByDuration(for: Date(), events: events, logs: todayLogs)
        } catch {
            errorMsg = "Local save failed: \(error.localizedDescription)"
        }
    }

    private func upsertLog(event: EventModel, emoji: EmojiType, note: String?) throws {
        let val = StateOfMindFactory.valence(for: emoji)

        if let existing = todayLogs.first(where: { $0.eventId == event.id }) {
            existing.emoji = emoji.emoji
            existing.valence = val
            existing.association = event.category.associationLabel
            existing.note = note
            existing.date = event.endDate
        } else {
            let m = MoodLog(eventId: event.id,
                            eventTitle: event.title,
                            date: event.endDate,
                            emoji: emoji.emoji,
                            valence: val,
                            association: event.category.associationLabel,
                            note: note)
            context.insert(m)
        }

        try context.save()
    }

    @MainActor
    private func saveSelection(event: EventModel, emoji: EmojiType) async {
        guard #available(iOS 18.0, *) else { return }
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let t = HKSampleType.stateOfMindType()
        guard hkStore.authorizationStatus(for: t) == .sharingAuthorized else {
            errorMsg = "HealthKit permission not granted."; return
        }
        do {
            let som = HKStateOfMind(
                date: event.endDate,
                kind: .momentaryEmotion,
                valence: StateOfMindFactory.valence(for: emoji),
                labels: [StateOfMindFactory.label(for: emoji)],
                associations: [StateOfMindFactory.association(for: event.category)],
                metadata: nil
            )
            try await somManager.save(sample: som)
        } catch {
            errorMsg = "HealthKit save failed: \(error.localizedDescription)"
        }
    }
}
