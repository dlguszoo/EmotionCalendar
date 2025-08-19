//
//  BalanceGaugeView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

struct BalanceGaugeView: View {
    let progress: Double
    let title: String
    
    var body: some View {
        VStack(spacing: -20) {
            GuageWithNumberView(progress: progress)
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
        }
    }
}

#Preview {
    BalanceGaugeView(progress: 0.5, title: "")
}
