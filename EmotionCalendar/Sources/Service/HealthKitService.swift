//
//  HealthKitService.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/18/25.
//

import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()
    
    // 읽기 및 쓰기 권한 설정
    let read = Set([HKSampleType.stateOfMindType()])
    let share = Set([HKObjectType.stateOfMindType()])
    
    func configure() {
        // 해당 장치가 healthkit을 지원하는지 여부
        if HKHealthStore.isHealthDataAvailable() {
            requestAuthorization()
        }
    }
    
    // 권한 요청 메소드
    private func requestAuthorization() {
        self.healthStore.requestAuthorization(toShare: share, read: read) { success, error in
            if error != nil {
                print(error.debugDescription)
            }else{
                if success {
                    print("권한이 허락되었습니다")
                }else{
                    print("권한이 없습니다")
                }
            }
        }
    }
}
