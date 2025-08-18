//
//  EventCategory.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import SwiftUI

enum EventCategory { case work, social, workout, other }

extension EventCategory {
    var associationLabel: String {
        switch self {
        case .work: return "work"
        case .social: return "social"
        case .workout: return "exercise"
        case .other: return "other"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .work: return .purple
        case .social: return .yellow
        case .workout: return .green
        case .other: return .cyan
        }
    }
}
