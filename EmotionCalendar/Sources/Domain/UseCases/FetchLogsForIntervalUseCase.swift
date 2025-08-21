//
//  FetchLogsForIntervalUseCase.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/21/25.
//

import Foundation

struct FetchLogsForIntervalUseCase {
    let logRepo: MoodLogRepository
    func execute(interval: DateInterval) throws -> [MoodLog] { try logRepo.fetchLogs(in: interval) }
}
