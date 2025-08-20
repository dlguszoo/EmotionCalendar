//
//  DefaultMoodLogRepository.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import SwiftData

class DefaultMoodLogRepository: MoodLogRepository {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func upsert(event: EventModel, emoji: EmojiType, note: String?) throws {
        // today 범위 필터는 View에서 이미 하고 있으므로, 단순 upsert
        let val = StateOfMindFactory.valence(for: emoji)
        if let existing = try? context.fetch(FetchDescriptor<MoodLog>(predicate: #Predicate { $0.eventId == event.id })).first {
            existing.emoji = emoji.emoji
            existing.valence = val
            existing.association = event.category.associationLabel
            existing.note = note
            existing.date = event.endDate
        } else {
            let m = MoodLog(eventId: event.id,
                            eventTitle: event.title,
                            date: event.endDate,
                            emoji: emoji.emoji,
                            valence: val,
                            association: event.category.associationLabel,
                            note: note)
            context.insert(m)
        }
        try context.save()
    }
}

