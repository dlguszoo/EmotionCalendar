//
//  FetchTodayEventsUseCase.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

struct FetchTodayEventsUseCase {
    let eventRepo: EventRepository
    func execute() async throws -> [EventModel] {
        try await eventRepo.fetchTodayEvents()
    }
}
