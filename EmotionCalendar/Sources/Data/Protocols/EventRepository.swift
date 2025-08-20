//
//  EventRepository.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

protocol EventRepository {
    func fetchTodayEvents() async throws -> [EventModel]
    func fetchWeekEvents(in interval: DateInterval) async throws -> [EventModel]
}
