//
//  EventKitFetcher.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import EventKit

final class EventKitFetcher {
    private let store = EKEventStore()

    func requestAccess() async throws {
        try await store.requestFullAccessToEvents()
    }

    func fetchToday(calendars: [EKCalendar]? = nil) -> [EventModel] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }

        return events.compactMap { ev in
            guard let id = ev.eventIdentifier else { return nil }
            return EventModel(
                id: id,
                title: ev.title ?? "(No Title)",
                startDate: ev.startDate,
                endDate: ev.endDate,
                category: guessCategory(from: ev)
            )
        }
    }

    private func guessCategory(from event: EKEvent) -> EventCategory {
        let name = (event.calendar.title).lowercased()
        if name.contains("work") || name.contains("office") || name.contains("meeting") { return .work }
        if name.contains("gym") || name.contains("run")     { return .workout }
        if name.contains("family") || name.contains("friends") { return .social }
        return .other
    }
}



