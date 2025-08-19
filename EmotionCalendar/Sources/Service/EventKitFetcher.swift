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
    
    func fetchWeek(in interval: DateInterval, calendars: [EKCalendar]? = nil) -> [EventModel] {
        let predicate = store.predicateForEvents(withStart: interval.start,
                                                 end: interval.end,
                                                 calendars: calendars)
        let events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        return events.compactMap { ev in
            guard let id = ev.eventIdentifier else { return nil }
            return EventModel(
                id: id,
                title: ev.title ?? "(No Title)",
                startDate: ev.startDate,
                endDate: ev.endDate,
                category: guessCategory(from: ev)   // 기존 추정 로직 재사용
            )
        }
    }

    private func guessCategory(from event: EKEvent) -> EventCategory {
        // 제목, 위치, 메모, 캘린더 이름을 모두 합쳐서 매칭
        let haystack = [
            event.title,
            event.location,
            event.notes,
            event.calendar.title
        ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")
        
        // 운동 키워드
        if haystack.contains("run") || haystack.contains("jog")
            || haystack.contains("workout") || haystack.contains("gym") {
            return .workout
        }
        
        // 업무 키워드
        if haystack.contains("work") || haystack.contains("office") || haystack.contains("meeting") {
            return .work
        }
        
        // 사회/가족 키워드
        if haystack.contains("friend") || haystack.contains("friends")
            || haystack.contains("family") || haystack.contains("social") {
            return .social
        }
        
        return .other
    }
}



