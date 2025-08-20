//
//  FetchWeekEventsUseCase.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

struct FetchWeekEventsUseCase {
    let eventRepo: EventRepository
    func execute(interval: DateInterval) async throws -> [EventModel] {
        try await eventRepo.fetchWeekEvents(in: interval)
    }
}
