//
//  MoodLogRepository.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

protocol MoodLogRepository {
    func fetchLogs(in interval: DateInterval) throws -> [MoodLog]
    func upsert(event: EventModel, emoji: EmojiType, note: String?) throws
}
