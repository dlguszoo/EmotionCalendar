//
//  GuageWithNumberView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

struct GuageWithNumberView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            ZStack {
                BackgroundCircleStroke()
                
                StateCircleStroke(progress: progress)
            }
            
            Text("\(Int(progress * 100))")
                .font(.system(size: 30, weight: .bold))
        }
    }
}

#Preview {
    GuageWithNumberView(progress: 0.5)
}
