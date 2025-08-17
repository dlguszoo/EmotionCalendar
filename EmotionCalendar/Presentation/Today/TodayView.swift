//
//  TodayView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationView {
            VStack {
                BalanceGaugeView(progress: 0.5)
            }
            .navigationTitle(MenuSection.today.rawValue)
        }
    }
}

#Preview {
    TodayView()
}
