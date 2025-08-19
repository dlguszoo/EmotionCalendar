//
//  InsightsView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI
import SwiftData
import EventKit
import HealthKit

struct InsightsView: View {
    @Environment(\.modelContext) private var context
    
    // 어떤 주를 볼지 결정하는 기준 날짜 (오늘 = 이번 주)
    @State private var anchorDate: Date = Date()
    
    // 선택된 주간 경계
    private var week: DateInterval { Calendar.weekInterval(containing: anchorDate) }
    
    private let ek = EventKitFetcher()
    private let hkStore: HKHealthStore
    private let somManager: StateOfMindManager
    
    init() {
        let store = HKHealthStore()
        self.hkStore = store
        self.somManager = StateOfMindManager(store: store)
    }
    
    // 데이터 소스
    @State private var weekEvents: [EventModel] = []
    @State private var weekLogs: [MoodLog] = []
    
    // UI 상태
    @State private var weeklyScore: Int = 0
    @State private var detailLog: MoodLog?
    
    // 하이라이트
    private var mostMeaningfulLog: MoodLog? { weekLogs.max(by: { $0.valence < $1.valence }) }
    private var mostBoringLog: MoodLog? { weekLogs.min(by: { $0.valence < $1.valence }) }
    private func event(for log: MoodLog?) -> EventModel? {
        guard let id = log?.eventId else { return nil }
        return weekEvents.first(where: { $0.id == id })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                BalanceGaugeView(progress: Double(weeklyScore) / 100.0, title: "Weekly Work-Life Balance")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Highlights").font(.title2).fontWeight(.bold)
                    
                    VStack(spacing: 5) {
                        MostEventCell(
                            mostTitle: "Most Meaningful Event 😊",
                            event: event(for: mostMeaningfulLog),
                            onTapDetail: { if let l = mostMeaningfulLog { detailLog = l } }
                        )
                        MostEventCell(
                            mostTitle: "Most Boring Event 🥱",
                            event: event(for: mostBoringLog),
                            onTapDetail: { if let l = mostBoringLog { detailLog = l } }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(MenuSection.weekly.rawValue)
        }
        .task { await reloadWeek() }
        .onChange(of: anchorDate) { _, _ in
            Task { await reloadWeek() }
        }
        .sheet(item: $detailLog) { log in
            MoodLogDetailSheet(log: log)
        }
    }
    
    // MARK: - 로딩 & 집계
    private func reloadWeek() async {
        do {
            try await ek.requestAccess()
            // EventKit: 해당 주간 이벤트
            weekEvents = ek.fetchWeek(in: week)
            
            // SwiftData: 해당 주간 MoodLog
            let fd = FetchDescriptor<MoodLog>(
                predicate: #Predicate { $0.date >= week.start && $0.date < week.end },
                sortBy: [SortDescriptor(\.date)]
            )
            weekLogs = (try? context.fetch(fd)) ?? []
            
            // 주간 work 시간 비율(로그 있으면 로그된 이벤트 기준, 없으면 전체 이벤트 기준)
            weeklyScore = somManager.weeklyWorkShareByDuration(in: week, events: weekEvents, logs: weekLogs)
        } catch {
            print("Insights reload failed: \(error)")
        }
    }
}

#Preview {
    InsightsView()
}
