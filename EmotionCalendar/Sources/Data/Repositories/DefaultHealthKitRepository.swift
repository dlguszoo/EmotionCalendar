//
//  DefaultHealthKitRepository.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import HealthKit

class DefaultHealthKitRepository: HealthKitRepository {
    private let store: HKHealthStore
    private let somManager: StateOfMindManager

    init(store: HKHealthStore = HKHealthStore()) {
        self.store = store
        self.somManager = StateOfMindManager(store: store)
    }

    @available(iOS 18.0, *)
    func saveStateOfMind(event: EventModel, emoji: EmojiType) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let t = HKSampleType.stateOfMindType()
        guard store.authorizationStatus(for: t) == .sharingAuthorized else {
            throw StateOfMindError.notAuthorized
        }
        try await somManager.save(event: event, emoji: emoji)
    }
}

