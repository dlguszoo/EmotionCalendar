//
//  HealthKitRepository.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

protocol HealthKitRepository {
    @available(iOS 18.0, *)
    func saveStateOfMind(event: EventModel, emoji: EmojiType) async throws
}
