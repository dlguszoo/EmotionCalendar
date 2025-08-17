//
//  EmotionCalendarApp.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/13/25.
//

import SwiftUI
import SwiftData

@main
struct EmotionCalendarApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MoodLog.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            BaseSegmentedPickerView()
        }
        .modelContainer(sharedModelContainer)
    }
}
