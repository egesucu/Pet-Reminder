//
//  FeedList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared

struct FeedList: View {

    let pet: Pet
    @Environment(\.modelContext) var context

    @State private var now = Date.now
    @State private var showSaveError = false
    @Environment(\.scenePhase) private var scenePhase

    private var morningOn: Bool { DailyFeeds.isFed(.morning, pet: pet, at: now) }
    private var eveningOn: Bool { DailyFeeds.isFed(.evening, pet: pet, at: now) }

    var body: some View {
        VStack(spacing: .spacing8) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: .spacing24) { feedButtons }
                VStack(spacing: .spacing16) { feedButtons }
            }
            if let defineText {
                Text(defineText)
                    .font(.title2.bold())
            }
        }
        .task {
            while !Task.isCancelled {
                now = .now
                let nextDay = Calendar.current.startOfDay(for: now).addingTimeInterval(36 * 60 * 60)
                let midnight = Calendar.current.startOfDay(for: nextDay)
                do {
                    try await Task.sleep(for: .seconds(max(1, midnight.timeIntervalSinceNow)))
                } catch { return }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { now = .now }
        }
        .alert(.saveFailed, isPresented: $showSaveError) { }
    }

    @ViewBuilder private var feedButtons: some View {
        if pet.feedSelection != .evening { morningButton }
        if pet.feedSelection != .morning { eveningButton }
    }

    var defineText: String? {
        switch pet.feedSelection {
        case .morning:
            return String(localized: morningOn ? "All feeds are given" : "0/1 feed given")
        case .evening:
            return String(localized: eveningOn ? "All feeds are given" : "0/1 feed given")
        case .both:
            let bothChecked = morningOn && eveningOn
            if bothChecked {
                return String(localized: "All feeds are given")
            } else if morningOn || eveningOn {
                return String(localized: "1/2 feed given")
            } else {
                return String(localized: "0/2 feed given")
            }
        }
    }

    var morningButton: some View {
        Button {
            toggle(.morning)
        } label: {
            Label {
                Text(.feedSelectionMorning)
                    .font(.title2.bold(morningOn))
                    .foregroundStyle(morningOn ? Color.background : Color.label)
            } icon: {
                Image(systemName: morningOn ? "checkmark" : "sun.max")
                    .font(.system(size: .icon20, weight: morningOn ? .bold : .regular))
                    .foregroundStyle(morningOn ? Color.background : Color.label)
            }
        }
        .buttonStyle(
            .glass(
                .regular
                    .interactive(morningOn)
                    .tint(morningOn ? .yellow : .yellow.opacity(0.4))
            )
        )
        .animation(.smooth, value: morningOn)
        .sensoryFeedback(.selection, trigger: morningOn)
        .onChange(of: morningOn) {
            Logger
                .feed
                .info("PR: Morning Changed, new value: \(morningOn), pet: \(pet.name)")
        }
    }

    var eveningButton: some View {
        Button {
            toggle(.evening)
        } label: {
            Label {
                Text(.feedSelectionEvening)
                    .font(.title2.bold(eveningOn))
                    .foregroundStyle(eveningOn ? Color.background : Color.label)
            } icon: {
                Image(systemName: eveningOn ? "checkmark" : "moon")
                    .font(.system(size: .icon20, weight: eveningOn ? .bold : .regular))
                    .foregroundStyle(eveningOn ? Color.background : Color.label)
            }
        }
        .buttonStyle(
            .glass(
                .regular
                    .interactive(
                        eveningOn
                    )
                    .tint(
                        eveningOn ? .blue : .blue.opacity(0.4)
                    )
            )
        )
        .animation(.smooth, value: eveningOn)
        .sensoryFeedback(.selection, trigger: eveningOn)
        .onChange(of: eveningOn) {
            Logger
                .feed
                .info("PR: Evening Changed, new value: \(eveningOn), pet: \(pet.name)")
        }
    }

    private func toggle(_ type: FeedSelection) {
        now = .now
        do {
            try DailyFeeds.toggle(type, pet: pet, at: now, context: context)
        } catch {
            showSaveError = true
        }
    }

}

#if DEBUG
#Preview {
    FeedList(pet: .preview)
        .modelContainer(DataController.previewContainer)

}
#endif
