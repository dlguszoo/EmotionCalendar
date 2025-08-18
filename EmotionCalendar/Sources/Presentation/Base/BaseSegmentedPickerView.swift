//
//  BaseSegmentedPickerView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

struct BaseSegmentedPickerView: View {
    @State var selectedSection: MenuSection = .today
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedSection) {
                ForEach(MenuSection.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 여기서 각 case에 따라 다른 View 표시
            contentView(for: selectedSection)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private func contentView(for section: MenuSection) -> some View {
        switch section {
        case .today:
            TodayView() // Today 화면
        case .insights:
            InsightsView() // Insights 화면
        }
    }
}

#Preview {
    BaseSegmentedPickerView()
}
