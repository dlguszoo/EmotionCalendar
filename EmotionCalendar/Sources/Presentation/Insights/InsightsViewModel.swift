//
//  InsightsViewModel.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/20/25.
//

import Foundation
import SwiftUI
import HealthKit
import Observation

@Observable
class InsightsViewModel {
    @Published var weekEvents: [EventModel] = []
    @Published var weeklyScore: Int = 0
    @Published var detailLog: MoodLog?
    
    private(set) var weekLogs: [MoodLog] = []
    private let ek = EventKitFetcher()
    private let somManager: StateOfMindManager
    
    init() {
        let store = HKHealthStore()
        self.somManager = StateOfMindManager(store: store)
    }
    
    func updateLogs(_ logs: [MoodLog]) {
        self.weekLogs = logs
    }
    
    func loadWeek(interval: DateInterval) async {
        do {
            try await ek.requestAccess()
            weekEvents = ek.fetchWeek(in: interval)
            weeklyScore = somManager.weeklyWorkShareByDuration(in: interval, events: weekEvents, logs: weekLogs)
        } catch {
            print("Insights reload failed: \(error)")
        }
    }
    
    // 하이라이트
    var mostMeaningfulLog: MoodLog? {
        weekLogs.max {
            if $0.valence == $1.valence {
                return $0.date < $1.date
            }
            return $0.valence < $1.valence
        }
    }
    
    var mostBoringLog: MoodLog? {
        weekLogs.min {
            if $0.valence == $1.valence {
                return $0.date < $1.date
            }
            return $0.valence < $1.valence
        }
    }
    
    func event(for log: MoodLog?) -> EventModel? {
        guard let id = log?.eventId else { return nil }
        return weekEvents.first(where: { $0.id == id })
    }
}
