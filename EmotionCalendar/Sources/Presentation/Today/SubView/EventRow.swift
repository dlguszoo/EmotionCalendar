//
//  EventRow.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/17/25.
//

import SwiftUI

struct EventRow: View {
    let event: EventModel
    let logged: MoodLog?              // nil이면 미기록, 있으면 기록됨
    let onTapLog: () -> Void          // 미기록 탭 → 로깅 시트 열기
    let onTapDetail: () -> Void       // 기록됨 탭 → 상세 시트 열기

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(event.title).font(.headline).foregroundStyle(.white)
                    if logged != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption).foregroundStyle(.white.opacity(0.9))
                    }
                }
                Text(timeRange(event)).font(.caption).foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: logged == nil ? "face.smiling" : "doc.text.magnifyingglass")
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .background(event.category.backgroundColor)
        .cornerRadius(14)
        .contentShape(Rectangle())
        .onTapGesture { logged == nil ? onTapLog() : onTapDetail() }
    }
    
    private func timeRange(_ ev: EventModel) -> String {
        "\(ev.startDate.formatted(date: .omitted, time: .shortened)) – \(ev.endDate.formatted(date: .omitted, time: .shortened))"
    }
}
