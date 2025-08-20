//
//  MostEventCell.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/19/25.
//

import SwiftUI

struct MostEventCell: View {
    let mostTitle: String
    let event: EventModel?
    let onTapDetail: () -> Void       // 상세 시트 열기

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mostTitle).font(.title3.bold()).foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 6) {
                if let ev = event {
                    Text(ev.title).font(.headline).foregroundStyle(.white)
                    Text(dateRange(ev)).font(.caption).foregroundStyle(.white)
                    Text(timeRange(ev)).font(.caption).foregroundStyle(.white)
                } else {
                    Text("No data yet").font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(event?.category.backgroundColor ?? .gray)
        .cornerRadius(14)
        .contentShape(Rectangle())
        .onTapGesture { if event != nil { onTapDetail() } }
    }
    
    private func dateRange(_ ev: EventModel) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // 영어 약어(Jun 등)
        formatter.dateFormat = "MMM d, yyyy"                // Jun 7, 2024

        let formatted = formatter.string(from: ev.startDate)
        return formatted
    }
    
    private func timeRange(_ ev: EventModel) -> String {
        "\(ev.startDate.formatted(date: .omitted, time: .shortened)) – \(ev.endDate.formatted(date: .omitted, time: .shortened))"
    }
}
