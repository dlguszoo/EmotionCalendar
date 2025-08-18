//
//  StateOfMindManager.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import HealthKit
import SwiftUI

@available(iOS 18.0, *)
enum StateOfMindError: Error {
    case healthDataUnavailable
    case notAuthorized
}

@available(iOS 18.0, *)
final class StateOfMindManager {
    // 같은 인스턴스를 주입받아 전체 앱에서 통일해서 쓰기
    private let store: HKHealthStore
    private let stateOfMindType: HKSampleType = HKSampleType.stateOfMindType()

    init(store: HKHealthStore) { self.store = store }

    // 읽기/쓰기 권한 세트 (권한 뷰에 그대로 넘기기 편하게)
    var shareTypes: Set<HKSampleType> { [stateOfMindType] }
    var readTypes: Set<HKObjectType>  { [HKObjectType.stateOfMindType()] }

    // 현재 공유 권한
    func isAuthorized() -> Bool {
        store.authorizationStatus(for: stateOfMindType) == .sharingAuthorized
    }

    // 저장 전에 공통 가드
    private func preflightChecks() throws {
        guard HKHealthStore.isHealthDataAvailable() else { throw StateOfMindError.healthDataUnavailable }
        guard isAuthorized() else { throw StateOfMindError.notAuthorized }
    }

    // 샘플 생성
    func makeSample(event: EventModel, emoji: EmojiType) -> HKStateOfMind {
        let kind: HKStateOfMind.Kind = .momentaryEmotion

        let valence = max(-1.0, min(1.0, StateOfMindFactory.valence(for: emoji)))
        let label  = StateOfMindFactory.label(for: emoji)
        let assoc  = StateOfMindFactory.association(for: event.category) // String→Association 매핑

        // (선택) 나중에 매칭/디버깅을 위한 메타데이터
        var metadata: [String: Any] = [:]
        metadata["event_id"] = event.id
        metadata["event_title"] = event.title

        return HKStateOfMind(
            date: event.endDate,
            kind: kind,
            valence: valence,
            labels: [label],
            associations: [assoc],
            metadata: metadata
        )
    }

    // 샘플 저장
    @discardableResult
    func save(sample: HKSample) async throws -> Bool {
        try preflightChecks()
        try await store.save(sample)
        return true
    }

    // 편의 메서드: 이벤트 + 이모지로 바로 저장
    @discardableResult
    func save(event: EventModel, emoji: EmojiType) async throws -> Bool {
        let sample = makeSample(event: event, emoji: emoji)
        return try await save(sample: sample)
    }
    
    @MainActor
    func dailyBalancePercent(for date: Date, store: HKHealthStore) async throws -> Int {
        let t = HKSampleType.stateOfMindType()
        guard store.authorizationStatus(for: t) != .notDetermined else { return 0 }

        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        let datePred = HKQuery.predicateForSamples(withStart: start, end: end)

        let pred = HKSamplePredicate.stateOfMind(datePred)
        let desc = HKSampleQueryDescriptor(predicates: [pred], sortDescriptors: [])
        let samples: [HKStateOfMind] = try await desc.result(for: store)
        guard !samples.isEmpty else { return 0 }

        let adjusted = samples.map { $0.valence + 1.0 }       // 0..2
        let avg = adjusted.reduce(0, +) / Double(samples.count)
        return Int(max(0, min(1, avg/2.0)) * 100.0)           // 0..100
    }
}

