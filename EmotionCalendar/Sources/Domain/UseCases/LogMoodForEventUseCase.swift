//
//  LogMoodForEventUseCase.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

/// HealthKit 저장 + SwiftData 업서트 오케스트레이션
struct LogMoodForEventUseCase {
    let healthRepo: HealthKitRepository
    let moodRepo: MoodLogRepository

    @MainActor
    func execute(event: EventModel, emoji: EmojiType, note: String?) async throws {
        if #available(iOS 18.0, *) {
            try await healthRepo.saveStateOfMind(event: event, emoji: emoji)
        }
        try moodRepo.upsert(event: event, emoji: emoji, note: note)
    }
}
