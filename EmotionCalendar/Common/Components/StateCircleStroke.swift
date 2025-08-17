//
//  StateCircleStroke.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

struct StateCircleStroke: View {
    let progress: Double
    
    var body: some View {
        HalfCircleShape()
            .trim(from: 0, to: progress)
            .stroke(Color.yellow, style: StrokeStyle(lineWidth: 20, lineCap: .round))
            .frame(width: 100, height: 100)
    }
}

#Preview {
    StateCircleStroke(progress: 0.5)
}
