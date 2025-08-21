//
//  InsightsViewModel.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/20/25.
//

import SwiftUI
import Observation

@Observable
class InsightsViewModel {
    var weekEvents: [EventModel] = []
    var weekLogs: [MoodLog] = []
    var weeklyScore: Int = 0
    var detailLog: MoodLog?
    
    private let fetchWeekEvents: FetchWeekEventsUseCase
    private let fetchLogsForInterval: FetchLogsForIntervalUseCase
    private let computeWeeklyScore: ComputeWeeklyScoreUseCase
    
    init(fetchWeekEvents: FetchWeekEventsUseCase,
         fetchLogsForInterval: FetchLogsForIntervalUseCase,
         computeWeeklyScore: ComputeWeeklyScoreUseCase) {
        self.fetchWeekEvents = fetchWeekEvents
        self.fetchLogsForInterval = fetchLogsForInterval
        self.computeWeeklyScore = computeWeeklyScore
    }
    
    func loadWeek(interval: DateInterval) async {
        do {
            async let evs = fetchWeekEvents.execute(interval: interval)
            let logs = try fetchLogsForInterval.execute(interval: interval)
            self.weekLogs = logs
            self.weekEvents = try await evs
            self.weeklyScore = computeWeeklyScore.execute(interval: interval, events: weekEvents, logs: weekLogs)
        } catch {
            print("Insights reload failed: \(error)")
        }
    }
    
    // 하이라이트
    var mostMeaningfulLog: MoodLog? {
        weekLogs.max {
            if $0.valence == $1.valence {
                return $0.date < $1.date
            }
            return $0.valence < $1.valence
        }
    }
    
    var mostBoringLog: MoodLog? {
        weekLogs.min {
            if $0.valence == $1.valence {
                return $0.date < $1.date
            }
            return $0.valence < $1.valence
        }
    }
    
    func event(for log: MoodLog?) -> EventModel? {
        guard let id = log?.eventId else { return nil }
        return weekEvents.first(where: { $0.id == id })
    }
}
