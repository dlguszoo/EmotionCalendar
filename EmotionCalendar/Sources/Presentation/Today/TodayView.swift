//
//  TodayView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI
import EventKit
import HealthKit
import SwiftData

// 오늘 범위(상수로 고정: @Query에서 사용)
private let startOfToday: Date = {
    Calendar.current.startOfDay(for: Date())
}()
private let endOfToday: Date = {
    Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
}()

struct TodayView: View {
    @Environment(\.modelContext) private var context

    // 오늘 저장된 MoodLog만 자동으로 구독
    @Query(
        filter: #Predicate<MoodLog> {
            $0.date >= startOfToday && $0.date < endOfToday
        },
        sort: \.date
    ) private var todayLogs: [MoodLog]

    private let ek = EventKitFetcher()
    @State private var hkStore = HKHealthStore()
    @State private var somManager: StateOfMindManager? = nil

    @State private var events: [EventModel] = []
    @State private var selectedEvent: EventModel? = nil   // 로깅 시트용
    @State private var detailLog: MoodLog? = nil          // 상세 시트용

    @State private var errorMsg: String?
    @State private var saving = false
    @State private var dailyScore: Int = 0

    // todayLogs → eventId 매핑(계산 프로퍼티: 캐시 불필요)
    private var logsById: [String: MoodLog] {
        Dictionary(uniqueKeysWithValues: todayLogs.map { ($0.eventId, $0) })
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 게이지: 0~100 → 0.0~1.0
                BalanceGaugeView(progress: Double(dailyScore) / 100.0)

                List {
                    ForEach(events) { ev in
                        EventRow(
                            event: ev,
                            logged: logsById[ev.id],
                            onTapLog:    { selectedEvent = ev },
                            onTapDetail: { if let l = logsById[ev.id] { detailLog = l } }
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(MenuSection.today.rawValue)
        }
        .onAppear {
            // 동일 HK 인스턴스로 매니저 1회 주입
            if somManager == nil, #available(iOS 18.0, *) {
                somManager = StateOfMindManager(store: hkStore)
            }
        }
        .task {
            do {
                try await ek.requestAccess()
                events = ek.fetchToday()
                // HealthKit: 오늘 점수 계산
                dailyScore = (try? await somManager?.dailyBalancePercent(for: Date(), store: hkStore)) ?? 0
            } catch {
                errorMsg = error.localizedDescription
            }
        }
        // 미기록 → 로깅 시트
        .sheet(item: $selectedEvent) { ev in
            LogStateOfMindSheet(event: ev) { emoji, note in
                Task { await saveAndPersist(event: ev, emoji: emoji, note: note) }
            }
        }
        // 기록됨 → 상세 시트
        .sheet(item: $detailLog) { log in
            MoodLogDetailSheet(log: log)
        }
        .alert("Error", isPresented: .constant(errorMsg != nil)) {
            Button("OK") { errorMsg = nil }
        } message: { Text(errorMsg ?? "") }
        .overlay {
            if saving {
                ProgressView("Saving…")
                    .padding().background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - SwiftData 업서트(@Query가 자동 반영)
    private func upsertLog(event: EventModel, emoji: EmojiType, note: String?) throws {
        let val = StateOfMindFactory.valence(for: emoji)

        if let existing = todayLogs.first(where: { $0.eventId == event.id }) {
            // 업데이트
            existing.emoji = emoji.emoji
            existing.valence = val
            existing.association = event.category.associationLabel
            existing.note = note
            existing.date = event.endDate
        } else {
            // 신규
            let m = MoodLog(eventId: event.id,
                            eventTitle: event.title,
                            date: event.endDate,
                            emoji: emoji.emoji,
                            valence: val,
                            association: event.category.associationLabel,
                            note: note)
            context.insert(m)
        }
        try context.save() // 저장하면 todayLogs가 자동 갱신됨
    }

    // MARK: - HealthKit 저장 + SwiftData 업서트 + 점수 갱신
    @MainActor
    private func saveAndPersist(event: EventModel, emoji: EmojiType, note: String?) async {
        saving = true; defer { saving = false }
        // 1) HealthKit 저장
        await saveSelection(event: event, emoji: emoji)
        // 2) SwiftData 저장
        do {
            try upsertLog(event: event, emoji: emoji, note: note)
            // 3) 게이지 갱신
            dailyScore = (try? await somManager?.dailyBalancePercent(for: Date(), store: hkStore)) ?? dailyScore
        } catch {
            errorMsg = "Local save failed: \(error.localizedDescription)"
        }
    }

    // 기존 저장 로직(권한 요청은 하지 않음 — App에서 완료 가정)
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
            if let mgr = somManager {
                _ = try await mgr.save(sample: som)
            } else {
                try await hkStore.save(som)
            }
        } catch {
            errorMsg = "HealthKit save failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    TodayView()
}
