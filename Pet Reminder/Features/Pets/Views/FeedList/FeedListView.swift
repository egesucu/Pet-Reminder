//
//  FeedListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import SFSafeSymbols
import Shared

struct FeedListView: View {

    @Binding var pet: Pet
    @Environment(\.modelContext) var context

    @State private var morningOn = false
    @State private var eveningOn = false
    @State private var stateChanged = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 30) {
                switch pet.feedSelection {
                case .morning:
                    morningButton
                case .evening:
                    eveningButton
                case .both:
                    morningButton
                    eveningButton
                case .none:
                    EmptyView()
                }
            }
            if let defineText = defineText() {
                Text(defineText)
                    .font(.title2)
                    .bold()
                    .transformEffect(.identity)
                    .animation(.easeInOut, value: stateChanged)
            }
        }
        .task {
            await fetchLatestFeed(for: pet)
        }
        .onChange(of: pet) {
            Task {
                await fetchLatestFeed(for: pet)
            }
        }
    }

    private func defineText() -> String? {
        if let feedSelection = pet.feedSelection {
            switch feedSelection {
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
        } else {
            return nil
        }
    }

    var morningButton: some View {
        Button {
            morningOn.toggle()
            stateChanged.toggle()
            updateFeed(pet: pet, type: .morning)
        } label: {
            Label {
                Text(.feedSelectionMorning)
                    .font(.title2.bold(morningOn))
                    .foregroundStyle(morningOn ? Color.background : Color.label)
            } icon: {
                Image(systemSymbol: morningOn ? .checkmark : .sunMax)
                    .font(.title2.bold(morningOn))
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
            eveningOn.toggle()
            stateChanged.toggle()
            updateFeed(pet: pet, type: .evening)
        } label: {
            Label {
                Text(.feedSelectionEvening)
                    .font(.title2.bold(eveningOn))
                    .foregroundStyle(eveningOn ? Color.background : Color.label)
            } icon: {
                Image(systemSymbol: eveningOn ? .checkmark : .moon)
                    .font(.title2.bold(eveningOn))
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

    func fetchLatestFeed(for pet: Pet) async {
        await getLatestFeed(pet: pet)
    }

    func todaysFeeds(pet: Pet?) -> [Feed] {
        guard let pet else { return [] }
        return pet
            .feeds?
            .filter { Calendar.current.isDateInToday($0.feedDate ?? .now) } ?? []
    }

    func updateFeed(pet: Pet?, type: FeedSelection) {
        let todaysFeed = todaysFeeds(pet: pet)

        if todaysFeed.isEmpty {
            // We don't have any feed history for today
            let feed = Feed()
            switch type {
            case .both:
                break // We won't pass this to update feed.
            case .morning:
                feed.morningFed = morningOn
                feed.morningFedStamp = morningOn ? .now : nil
            case .evening:
                feed.eveningFedStamp = eveningOn ? .now : nil
                feed.eveningFed = eveningOn
            }
            feed.feedDate = .now
            pet?.feeds?.append(feed)

        } else {
            // We have a feed, let's update inside of it.
            guard let feed = todaysFeed.first else { return }
            switch type {
            case .both:
                break // We won't pass this to update feed.
            case .morning:
                feed.morningFed = morningOn
                feed.morningFedStamp = morningOn ? .now : nil
            case .evening:
                feed.eveningFedStamp = eveningOn ? .now : nil
                feed.eveningFed = eveningOn
            }

            feed.feedDate = .now
        }
        do {
            try context.save()
        } catch {
            Logger.feed.error("Error occurred while saving: \(error.localizedDescription)")
        }
    }

    func getLatestFeed(pet: Pet?) async {
        let todaysFeed = todaysFeeds(pet: pet)

        if todaysFeed.isEmpty {
            morningOn = false
            eveningOn = false
        } else {
            guard let feed = todaysFeed.first else { return }
            morningOn = feed.morningFed
            eveningOn = feed.eveningFed
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var pet = Pet.preview

    FeedListView(pet: $pet)
        .modelContainer(DataController.previewContainer)

}
#endif
