//
//  ComputeWeeklyScoreUseCase.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

struct ComputeWeeklyScoreUseCase {
    private let calculator = WorkShareCalculator()
    func execute(interval: DateInterval, events: [EventModel], logs: [MoodLog]) -> Int {
        calculator.weeklyWorkShare(interval: interval, events: events, logs: logs)
    }
}
