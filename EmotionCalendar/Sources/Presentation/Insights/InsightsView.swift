//
//  InsightsView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI
import SwiftData

private let anchorDate: Date = {
    Calendar.current.startOfDay(for: Date())
}()

private let week: DateInterval = {
    Calendar.weekInterval(containing: anchorDate)
}()

struct InsightsView: View {
    @Environment(\.modelContext) private var context
    
    @Query(
        filter: #Predicate<MoodLog> {
            $0.date >= week.start && $0.date < week.end
        },
        sort: \.date
    ) private var weekLogs: [MoodLog]
    
    @Bindable private var viewModel: InsightsViewModel
    
    init() {
        self.viewModel = .init()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                BalanceGaugeView(progress: Double(viewModel.weeklyScore) / 100.0, title: "Weekly Work-Life Balance")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Highlights").font(.title2).fontWeight(.bold)
                    
                    VStack(spacing: 5) {
                        MostEventCell(
                            mostTitle: "Most Meaningful Event 😊",
                            event: viewModel.event(for: viewModel.mostMeaningfulLog),
                            onTapDetail: { if let l = viewModel.mostMeaningfulLog { viewModel.detailLog = l } }
                        )
                        MostEventCell(
                            mostTitle: "Most Boring Event 🥱",
                            event: viewModel.event(for: viewModel.mostBoringLog),
                            onTapDetail: { if let l = viewModel.mostBoringLog { viewModel.detailLog = l } }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(MenuSection.weekly.rawValue)
        }
        .task { viewModel.updateLogs(weekLogs)
            await viewModel.loadWeek(interval: week) }
        .onChange(of: anchorDate) { _, _ in
            Task { viewModel.updateLogs(weekLogs)
                await viewModel.loadWeek(interval: week) }
        }
        .sheet(item: $viewModel.detailLog) { log in
            MoodLogDetailSheet(log: log)
        }
    }
}

#Preview {
    InsightsView()
}
