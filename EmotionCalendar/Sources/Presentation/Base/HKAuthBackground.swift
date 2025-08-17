//
//  HKAuthBackground.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import SwiftUI
import HealthKit
import HealthKitUI

private let healthStore = HKHealthStore()

struct HKAuthBackground: View {
    @Binding var trigger: Bool
    @Binding var authorized: Bool
    @Binding var errorMessage: String?
    
    var body: some View {
        healthDataAccessRequest(
            store: healthStore,
            shareTypes: [/* Xcode에서 확인: */ HKSampleType.stateOfMindType()],
            readTypes: nil,
            trigger: trigger
        ) { result in
            switch result {
            case .success(let ok): authorized = ok
            case .failure(let err): errorMessage = err.localizedDescription
            }
        }
    }
}

//#Preview {
//    HKAuthBackground(trigger: , authorized: , errorMessage: )
//}
