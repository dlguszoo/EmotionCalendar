//
//  DefaultEventRepository.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

class DefaultEventRepository: EventRepository {
    private let fetcher: EventKitFetcher

    init(fetcher: EventKitFetcher = EventKitFetcher()) {
        self.fetcher = fetcher
    }

    func fetchTodayEvents() async throws -> [EventModel] {
        try await fetcher.requestAccess()
        return fetcher.fetchToday()
    }

    func fetchWeekEvents(in interval: DateInterval) async throws -> [EventModel] {
        try await fetcher.requestAccess()
        return fetcher.fetchWeek(in: interval)
    }
}

