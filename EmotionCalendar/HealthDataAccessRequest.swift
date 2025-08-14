//
//  HealthDataAccessRequest.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/13/25.
//

import HealthKitUI

func healthDataAccessRequest(
    store: HKHealthStore,
    shareTypes: Set<HKSampleType>,
    readTypes: Set<HKObjectType>? = nil,
    trigger: some Equatable,
    completion: @escaping (Result<Bool, any Error>) -> Void
) -> some View
