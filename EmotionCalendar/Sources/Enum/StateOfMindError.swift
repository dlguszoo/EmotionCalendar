//
//  StateOfMindError.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/20/25.
//

import SwiftUI

@available(iOS 18.0, *)
enum StateOfMindError: Error {
    case healthDataUnavailable
    case notAuthorized
}
