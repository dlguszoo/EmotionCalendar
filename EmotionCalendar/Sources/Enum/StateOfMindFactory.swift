//
//  StateOfMindFactory.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import HealthKit

@available(iOS 18.0, *)
enum StateOfMindFactory {
    // 1) Label 매핑
    static func label(for emoji: EmojiType) -> HKStateOfMind.Label {
        switch emoji {
        case .angry:       return .angry
        case .sad:         return .sad
        case .indifferent: return .indifferent
        case .satisfied:   return .satisfied
        case .happy:       return .happy
        }
    }

    // 2) Association 매핑
    static func association(from eventAssociationName: String) -> HKStateOfMind.Association {
        switch eventAssociationName.lowercased() {
        case "work":     return .work
        case "social":   return .community
        case "exercise": return .fitness
        default:
            return .tasks
        }
    }
    
    // 3) valence 매핑
    static func valence(for emoji: EmojiType) -> Double {
        let v: Double
        switch emoji {
        case .angry:       v = -0.9
        case .sad:         v = -0.5
        case .indifferent: v =  0.0
        case .satisfied:   v =  0.5
        case .happy:       v =  0.9
        }
        // 안전하게 클램프
        return max(-1.0, min(1.0, v))
    }
}

