//
//  ComputeDailyScoreUseCase.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

struct ComputeDailyScoreUseCase {
    private let calculator = WorkShareCalculator()
    func execute(date: Date, events: [EventModel], logs: [MoodLog]) -> Int {
        calculator.dailyWorkShare(date: date, events: events, logs: logs)
    }
}
