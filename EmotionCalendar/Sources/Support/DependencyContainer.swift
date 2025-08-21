//
//  DependencyContainer.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import SwiftData
import SwiftUI

final class DependencyContainer {
    // Repos
    let eventRepo: EventRepository
    let logRepo: MoodLogRepository
    let healthRepo: HealthKitRepository

    // UseCases
    let fetchTodayEvents: FetchTodayEventsUseCase
    let fetchWeekEvents: FetchWeekEventsUseCase
    let fetchLogsForInterval: FetchLogsForIntervalUseCase
    let computeDailyScore: ComputeDailyScoreUseCase
    let computeWeeklyScore: ComputeWeeklyScoreUseCase
    let logMoodForEvent: LogMoodForEventUseCase
    
    init(context: ModelContext) {
        let eventRepo = DefaultEventRepository()
        let logRepo = DefaultMoodLogRepository(context: context)
        let healthRepo = DefaultHealthKitRepository()
        
        self.eventRepo = eventRepo
        self.logRepo = logRepo
        self.healthRepo = healthRepo
        
        self.fetchTodayEvents = FetchTodayEventsUseCase(eventRepo: eventRepo)
        self.fetchWeekEvents = FetchWeekEventsUseCase(eventRepo: eventRepo)
        self.fetchLogsForInterval = FetchLogsForIntervalUseCase(logRepo: logRepo)
        self.computeDailyScore = ComputeDailyScoreUseCase()
        self.computeWeeklyScore = ComputeWeeklyScoreUseCase()
        self.logMoodForEvent = LogMoodForEventUseCase(healthRepo: healthRepo, moodRepo: logRepo)
    }
}
