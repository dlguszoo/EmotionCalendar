//
//  MoodLogDetailSheet.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/18/25.
//

import SwiftUI

struct MoodLogDetailSheet: View, Identifiable {
    let id = UUID()
    let log: MoodLog
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(log.eventTitle).font(.headline)
                HStack {
                    Text("Feeling: \(log.emoji)")
                    Text("Valence: \(String(format: "%.2f", log.valence))")
                }
                .font(.subheadline)
                Text("Association: \(log.association)").font(.subheadline)
                if let note = log.note, !note.isEmpty {
                    Text("Note").font(.caption).foregroundStyle(.secondary)
                    Text(note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("No note").foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Logged Detail")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}
