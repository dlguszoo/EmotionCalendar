//
//  TodayViewModel.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/20/25.
//

import SwiftUI
import Observation

@Observable
class TodayViewModel {
    var events: [EventModel] = []
    var todayLogs: [MoodLog] = []
    var selectedEvent: EventModel? // 로깅 시트용
    var detailLog: MoodLog? // 상세 시트용
    var errorMsg: String?
    var saving = false
    var dailyScore: Int = 0
    
    var todayInterval: DateInterval {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }
   
    // UseCases
    private let fetchTodayEvents: FetchTodayEventsUseCase
    private let fetchLogsForInterval: FetchLogsForIntervalUseCase
    private let computeDailyScore: ComputeDailyScoreUseCase
    private let logMoodForEvent: LogMoodForEventUseCase
    
    init(fetchTodayEvents: FetchTodayEventsUseCase,
         fetchLogsForInterval: FetchLogsForIntervalUseCase,
         computeDailyScore: ComputeDailyScoreUseCase,
         logMoodForEvent: LogMoodForEventUseCase) {
        self.fetchTodayEvents = fetchTodayEvents
        self.fetchLogsForInterval = fetchLogsForInterval
        self.computeDailyScore = computeDailyScore
        self.logMoodForEvent = logMoodForEvent
    }

    var logsById: [String: MoodLog] {
        Dictionary(uniqueKeysWithValues: todayLogs.map { ($0.eventId, $0) })
    }

    func loadToday() async {
        do {
            async let evs = fetchTodayEvents.execute()
            let logs = try fetchLogsForInterval.execute(interval: todayInterval)
            self.todayLogs = logs
            self.events = try await evs
            self.dailyScore = computeDailyScore.execute(date: Date(), events: events, logs: todayLogs)
        } catch {
            self.errorMsg = error.localizedDescription
        }
    }

    @MainActor
    func logEvent(event: EventModel, emoji: EmojiType, note: String?) async {
        saving = true; defer { saving = false }
        do {
            try await logMoodForEvent.execute(event: event, emoji: emoji, note: note)
            await loadToday() // 저장 후 재조회
        } catch {
            self.errorMsg = error.localizedDescription
        }
    }
}
