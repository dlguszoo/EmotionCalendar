//
//  BackgroundCircleStroke.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

struct BackgroundCircleStroke: View {
    var body: some View {
        HalfCircleShape()
            .stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 20, lineCap: .round))
            .frame(width: 100, height: 100)
    }
}

#Preview {
    BackgroundCircleStroke()
}
