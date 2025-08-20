//
//  EventModel.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import SwiftUI

// EventKit에서 가져온 이벤트를 화면/저장에 쓰기 위한 모델
struct EventModel: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let category: EventCategory
    var association: String { category.associationLabel }
}
