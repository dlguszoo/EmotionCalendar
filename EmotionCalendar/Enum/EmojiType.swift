//
//  EmojiType.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/13/25.
//

import Foundation

enum EmojiType: CaseIterable {
    case angry
    case sad
    case indifferent
    case satisfied
    case happy
    
    var emoji: String {
        switch self {
        case .angry: return "😡"
        case .sad: return "😢"
        case .indifferent: return "😐"
        case .satisfied: return "😌"
        case .happy: return "😊"
        }
    }
}

//func createSample(for event: EventModel, emojiType: EmojiType) -> HKStateOfMind {
//    let kind: HKStateOfMind.Kind = .momentaryEmotion
//    let valence: Double = emojiType.valenece
//    let label = emojiType.label
//    let association = event.association
//    return HKStateOfMind(date: event.endDate,
//                         kind: kind,
//                         valence: valence,
//                         labels: [label],
//                         associations: [association])
//}
