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

//    var valence: Double {
//        switch self {
//        case .angry:       return -0.9
//        case .sad:         return -0.5
//        case .indifferent: return  0.0
//        case .satisfied:   return  0.5
//        case .happy:       return  0.9
//        }
//    }
//    
//    var label: String {
//        switch self {
//        case .angry:       return "Angry"
//        case .sad:         return "Sad"
//        case .indifferent: return "Indifferent"
//        case .satisfied:   return "Satisfied"
//        case .happy:       return "Happy"
//        }
//    }
}
