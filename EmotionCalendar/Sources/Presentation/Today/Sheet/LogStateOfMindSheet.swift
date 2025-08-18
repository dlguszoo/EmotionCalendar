//
//  LogStateOfMindSheet.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI

// MARK: - 이모지 선택 시트
struct LogStateOfMindSheet: View {
    let event: EventModel
    let onSave: (EmojiType, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selected: EmojiType? = nil
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text("How did \"\(event.title)\" go?")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 16) {
                    ForEach(EmojiType.allCases, id: \.self) { e in
                        Text(e.emoji)
                            .font(.system(size: 40))
                            .padding(5)
                            .background(Circle().fill(selected == e ? Color.yellow.opacity(0.25) : .clear))
                            .onTapGesture { selected = e }
                    }
                }
                
                TextField("Add a short note (optional)", text: $note)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    guard let s = selected else { return }
                    onSave(s, note.isEmpty ? nil : note)
                    dismiss()
                } label: {
                    Text("Save to HealthKit")
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selected == nil)
                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle("Log State of Mind")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
