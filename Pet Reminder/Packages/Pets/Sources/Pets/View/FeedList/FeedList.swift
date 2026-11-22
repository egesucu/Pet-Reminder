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
import SharedUI
import PetCare
#if DEBUG
import PreviewSupport
#endif

struct FeedList: View {

    let pet: Pet
    @Environment(\.modelContext) var context

    @State private var now = Date.now
    @State private var showSaveError = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
        .alert(SharedStrings.saveFailed, isPresented: $showSaveError) { }
    }

    @ViewBuilder private var feedButtons: some View {
        if pet.feedSelection != .evening { morningButton }
        if pet.feedSelection != .morning { eveningButton }
    }

    var defineText: String? {
        switch pet.feedSelection {
        case .morning:
            return String(localized: morningOn ? "All feeds are given" : "0/1 feed given", bundle: SharedResources.bundle)
        case .evening:
            return String(localized: eveningOn ? "All feeds are given" : "0/1 feed given", bundle: SharedResources.bundle)
        case .both:
            let bothChecked = morningOn && eveningOn
            if bothChecked {
                return String(localized: "All feeds are given", bundle: SharedResources.bundle)
            } else if morningOn || eveningOn {
                return String(localized: "1/2 feed given", bundle: SharedResources.bundle)
            } else {
                return String(localized: "0/2 feed given", bundle: SharedResources.bundle)
            }
        }
    }

    var morningButton: some View {
        feedButton(
            title: SharedStrings.feedSelectionMorning,
            symbol: "sun.max",
            isFed: morningOn,
            type: .morning
        )
        .onChange(of: morningOn) {
            Logger.feed.info("PR: Morning Changed, new value: \(morningOn), pet: \(pet.name)")
        }
    }

    var eveningButton: some View {
        feedButton(
            title: SharedStrings.feedSelectionEvening,
            symbol: "moon",
            isFed: eveningOn,
            type: .evening
        )
        .onChange(of: eveningOn) {
            Logger.feed.info("PR: Evening Changed, new value: \(eveningOn), pet: \(pet.name)")
        }
    }

    private func feedButton(
        title: LocalizedStringResource,
        symbol: String,
        isFed: Bool,
        type: FeedSelection
    ) -> some View {
        Button {
            toggle(type)
        } label: {
            Label {
                Text(title)
                    .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: isFed ? "checkmark" : symbol)
            }
            .font(.title2.bold(isFed))
            .foregroundStyle(.primary)
            .padding(.horizontal, .spacing16)
            .frame(minHeight: 44)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
            .overlay {
                Capsule().strokeBorder(.primary, lineWidth: isFed ? 2 : 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(Text(isFed ? SharedStrings.resource("Fed") : SharedStrings.resource("Not fed")))
        .animation(reduceMotion ? nil : .smooth, value: isFed)
        .sensoryFeedback(.selection, trigger: isFed)
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
        .modelContainer(PreviewData.previewContainer)

}
#endif
