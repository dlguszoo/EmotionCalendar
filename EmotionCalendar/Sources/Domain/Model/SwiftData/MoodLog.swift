//
//  MoodLog.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import SwiftUI
import SwiftData

@Model
final class MoodLog {
    @Attribute(.unique) var eventId: String
    var eventTitle: String
    var date: Date             // 저장 시각(또는 이벤트 endDate)
    var emoji: String          // UI용 이모지
    var valence: Double        // -1...+1
    var association: String    // "work"/"social"/"exercise"/"other"
    var note: String?          // 메모

    init(eventId: String, eventTitle: String, date: Date, emoji: String, valence: Double, association: String, note: String?) {
        self.eventId = eventId
        self.eventTitle = eventTitle
        self.date = date
        self.emoji = emoji
        self.valence = valence
        self.association = association
        self.note = note
    }
}

