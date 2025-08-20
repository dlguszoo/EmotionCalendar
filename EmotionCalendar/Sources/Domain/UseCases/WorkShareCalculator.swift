//
//  WorkShareCalculator.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

struct WorkShareCalculator {
    func dailyWorkShare(date: Date, events: [EventModel], logs: [MoodLog]) -> Int {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        let dayEnd   = cal.date(byAdding: .day, value: 1, to: dayStart)!

        let loggedIds = Set(logs.map { $0.eventId })
        let loggedEvents = events.filter { loggedIds.contains($0.id) }

        func clippedDuration(_ ev: EventModel) -> TimeInterval {
            let start = max(ev.startDate, dayStart)
            let end   = min(ev.endDate, dayEnd)
            return max(0, end.timeIntervalSince(start))
        }

        let total = loggedEvents.reduce(0.0) { $0 + clippedDuration($1) }
        let work  = loggedEvents.reduce(0.0) { $0 + ($1.category == .work ? clippedDuration($1) : 0) }

        guard total > 0 else { return 0 }
        return Int(((work / total) * 100.0).rounded())
    }

    func weeklyWorkShare(interval: DateInterval, events: [EventModel], logs: [MoodLog]) -> Int {
        var base = events
        if !logs.isEmpty {
            let ids = Set(logs.map { $0.eventId })
            let logged = events.filter { ids.contains($0.id) }
            if !logged.isEmpty { base = logged }
        }

        func clipped(_ ev: EventModel) -> TimeInterval {
            let s = max(ev.startDate, interval.start)
            let e = min(ev.endDate, interval.end)
            return max(0, e.timeIntervalSince(s))
        }

        let total = base.reduce(0.0) { $0 + clipped($1) }
        let work  = base.reduce(0.0) { $0 + ($1.category == .work ? clipped($1) : 0) }
        guard total > 0 else { return 0 }
        return Int(((work / total) * 100.0).rounded())
    }
}
