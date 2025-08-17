//
//  MoodLog.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import SwiftUI
import SwiftData

// 사용자가 남긴 감정 기록(메모 포함)을 로컬에 보존
@Model final class MoodLog {
    @Attribute(.unique) var id: UUID
    var eventId: String
    var eventTitle: String
    var eventStart: Date
    var eventEnd: Date
    var category: String

    var emoji: String
    var valence: Double
    var note: String?
    var createdAt: Date

    init(event: EventModel, emoji: EmojiType, valence: Double, note: String?) {
        self.id = UUID()
        self.eventId = event.id
        self.eventTitle = event.title
        self.eventStart = event.startDate
        self.eventEnd = event.endDate
        self.category = event.category.associationLabel
        self.emoji = emoji.emoji
        self.valence = valence
        self.note = note
        self.createdAt = Date()
    }
}
