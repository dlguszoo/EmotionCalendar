//
//  StateOfMindManager.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import HealthKit
import SwiftUI

final class StateOfMindManager {
    private let store = HKHealthStore()
    private let stateOfMindType: HKSampleType = HKSampleType.stateOfMindType()
    
    // 현재 공유 권한
    func isAuthorized() -> Bool {
        store.authorizationStatus(for: stateOfMindType) == .sharingAuthorized
    }
    
    // 샘플 생성 (WWDC 스타일)
    func makeSample(event: EventModel, emoji: EmojiType) -> HKStateOfMind {
        let kind: HKStateOfMind.Kind = .momentaryEmotion
        
        // 안전하게 클램핑
        let valence = max(-1.0, min(1.0, emojiType.valence))
        let label  = StateOfMindFactory.label(for: emojiType)
        let assoc  = StateOfMindFactory.association(from: event.association)
        
        return HKStateOfMind(
            date: event.endDate,
            kind: kind,
            valence: emoji.valence,
            labels: [label],            
            associations: [assoc]
        )
    }
    
    // 저장
    @discardableResult
    func save(sample: HKSample) async throws -> Bool {
        try await store.save(sample)
        return true
    }
    
    // 편의 메서드: 이벤트 + 이모지로 바로 저장
    @discardableResult
    func save(event: EventModel, emoji: EmojiType) async throws -> Bool {
        let sample = makeSample(event: event, emoji: emoji)
        return try await save(sample: sample)
    }
    
}
