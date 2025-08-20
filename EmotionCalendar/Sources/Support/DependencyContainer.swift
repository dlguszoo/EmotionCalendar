//
//  DependencyContainer.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import SwiftData
import HealthKit
import SwiftUI

final class DependencyContainer {
    // Repositories
    let eventRepo: EventRepository
    let moodRepo: MoodLogRepository
    let healthRepo: HealthKitRepository

    // UseCases
    let fetchTodayEvents: FetchTodayEventsUseCase
    let fetchWeekEvents: FetchWeekEventsUseCase
    let computeDailyScore: ComputeDailyScoreUseCase
    let computeWeeklyScore: ComputeWeeklyScoreUseCase
    let logMoodForEvent: LogMoodForEventUseCase

    init(context: ModelContext) {
        let eventRepo = DefaultEventRepository()
        let moodRepo  = DefaultMoodLogRepository(context: context)
        let healthRepo = DefaultHealthKitRepository()

        self.eventRepo = eventRepo
        self.moodRepo = moodRepo
        self.healthRepo = healthRepo

        self.fetchTodayEvents = FetchTodayEventsUseCase(eventRepo: eventRepo)
        self.fetchWeekEvents  = FetchWeekEventsUseCase(eventRepo: eventRepo)
        self.computeDailyScore = ComputeDailyScoreUseCase()
        self.computeWeeklyScore = ComputeWeeklyScoreUseCase()
        self.logMoodForEvent = LogMoodForEventUseCase(healthRepo: healthRepo, moodRepo: moodRepo)
    }
}
