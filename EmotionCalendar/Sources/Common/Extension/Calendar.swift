//
//  Calendar.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/19/25.
//

import Foundation

extension Calendar {
    static func weekInterval(containing date: Date) -> DateInterval {
        if let iv = Calendar.current.dateInterval(of: .weekOfYear, for: date) {
            return iv
        }
        //fallback: 해당 주의 시작/끝을 수동 계산
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
        return DateInterval(start: start, end: end)
    }
}
