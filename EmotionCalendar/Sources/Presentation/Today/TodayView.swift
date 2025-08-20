//
//  TodayView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI
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

    @Bindable private var viewModel: TodayViewModel
    
    init() {
        self.viewModel = .init(context: self.context)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 7) {
                // 게이지: 0~100 → 0.0~1.0
                BalanceGaugeView(progress: Double(viewModel.dailyScore) / 100.0, title: "Daily Work-Life Balance")

                List {
                    ForEach(viewModel.events) { ev in
                        EventRow(
                            event: ev,
                            logged: viewModel.logsById[ev.id],
                            onTapLog:    { viewModel.selectedEvent = ev },
                            onTapDetail: { if let l = viewModel.logsById[ev.id] { viewModel.detailLog = l } }
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.updateLogs(todayLogs)
                    await viewModel.loadToday()
                }
            }
            .navigationTitle(MenuSection.today.rawValue)
        }
        .task {
            viewModel.updateLogs(todayLogs)
            await viewModel.loadToday()
        }
        // 미기록 → 로깅 시트
        .sheet(item: $viewModel.selectedEvent) { ev in
            LogStateOfMindSheet(event: ev) { emoji, note in
                Task { await viewModel.logEvent(event: ev, emoji: emoji, note: note) }
            }
        }
        // 기록됨 → 상세 시트
        .sheet(item: $viewModel.detailLog) { log in
            MoodLogDetailSheet(log: log)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMsg != nil)) {
            Button("OK") { viewModel.errorMsg = nil }
        } message: { Text(viewModel.errorMsg ?? "") }
        .overlay {
            if viewModel.saving {
                ProgressView("Saving…")
                    .padding().background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    TodayView()
}
