//
//  TodayView.swift
//  EmotionCalendar
//
//  Created by 이현주 on 8/14/25.
//

import SwiftUI
import EventKit
import HealthKit
import HealthKitUI

struct TodayView: View {
    private let ek = EventKitFetcher()
    private let hkStore = HKHealthStore()
    
    @State private var events: [EventModel] = []
    @State private var selectedEvent: EventModel? = nil
    
    // 권한/상태
    @State private var hkTrigger = false
    @State private var hkAuthorized = false
    @State private var errorMsg: String?
    @State private var saving = false
    
    private let ekStore = EKEventStore()
    
    var body: some View {
        NavigationView {
            VStack {
                BalanceGaugeView(progress: 0.5)
                
                List(events) { ev in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ev.title).font(.headline)
                            Text("\(ev.startDate.formatted(date: .omitted, time: .shortened)) – \(ev.endDate.formatted(date: .omitted, time: .shortened))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "face.smiling").foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedEvent = ev }
                }
            }
            .navigationTitle(MenuSection.today.rawValue)
        }
        // HealthKit 권한 뷰(WWDC 헬퍼) — 백그라운드에 깔아두기
        .background(
            healthDataAccessRequest(
                store: hkStore,
                shareTypes: [HKSampleType.stateOfMindType()], // Xcode에서 심볼 확인
                readTypes: nil,
                trigger: hkTrigger
            ) { result in
                switch result {
                case .success(let ok): hkAuthorized = ok
                case .failure(let err): errorMsg = err.localizedDescription
                }
            }
                .opacity(0.01)
        )
        .task {
            do {
                try await ek.requestAccess()
                events = ek.fetchToday()
            } catch {
                errorMsg = error.localizedDescription
            }
        }
        // 시트: 이모지 선택 후 저장
        .sheet(item: $selectedEvent) { ev in
            LogStateOfMindSheet(event: ev) { emoji, _ in
                Task { await saveSelection(event: ev, emoji: emoji) }
            }
        }
        // 에러/인디케이터
        .alert("Error", isPresented: .constant(errorMsg != nil)) { Button("OK") { errorMsg = nil } } message: { Text(errorMsg ?? "") }
        .overlay {
            if saving {
                ProgressView("Saving…")
                    .padding().background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // 실제 저장 로직
    @MainActor
    private func saveSelection(event: EventModel, emoji: EmojiType) async {
        // 권한 없으면 트리거로 요청
        if hkStore.authorizationStatus(for: HKSampleType.stateOfMindType()) != .sharingAuthorized && !hkAuthorized {
            hkTrigger.toggle()
            return
        }
        saving = true; defer { saving = false }
        do {
            // HKStateOfMind 생성 (정식 enum 사용)
            let som = HKStateOfMind(
                date: event.endDate,
                kind: .momentaryEmotion,
                valence: StateOfMindFactory.valence(for: emoji),
                labels: [StateOfMindFactory.label(for: emoji)],
                associations: [StateOfMindFactory.association(from: event.association)],
                metadata: [
                    "event_id": event.id,
                    "event_title": event.title
                ]
            )
            try await hkStore.save(som)
            // (옵션) SwiftData 로컬 로그 저장은 여기서 후킹
        } catch {
            errorMsg = "HealthKit save failed: \(error.localizedDescription)"
        }
    }
}


#Preview {
    TodayView()
}
