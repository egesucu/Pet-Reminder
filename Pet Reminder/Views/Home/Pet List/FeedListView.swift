//
//  FeedListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct FeedListView: View {

    @Binding var morningOn: Bool
    @Binding var eveningOn: Bool
    @Environment(\.modelContext) var modelContext

    var pet: Pet = .init()

    let feedback = UINotificationFeedbackGenerator()

    var body: some View {
        HStack(spacing: 30) {
            switch pet.selection {
            case .morning:
                MorningCheckboxView(morningOn: $morningOn)
                    .onChange(of: morningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .morning, value: morningOn)
                    })
                    .onTapGesture {
                        morningOn.toggle()
                    }
            case .evening:
                EveningCheckboxView(eveningOn: $eveningOn)
                    .onChange(of: eveningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .evening, value: eveningOn)
                    })
                    .onTapGesture {
                        eveningOn.toggle()
                    }
            case .both:
                MorningCheckboxView(morningOn: $morningOn)
                    .onChange(of: morningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .morning, value: morningOn)
                    })
                    .onTapGesture {
                        morningOn.toggle()
                    }
                EveningCheckboxView(eveningOn: $eveningOn)
                    .onChange(of: eveningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .evening, value: eveningOn)
                    })
                    .onTapGesture {
                        eveningOn.toggle()
                    }
            }
        }
    }

    var todaysFeeds: [Feed] {
        pet.feeds?.filter { feed in
            Calendar.current.isDateInToday(feed.feedDate ?? .now)
        } ?? []

    }

    func updateFeed(type: FeedTimeSelection, value: Bool) {

        if todaysFeeds.isEmpty {
            addFeedForToday(value: value)
        } else {
            if let feeds = pet.feeds,
               let lastFeed = feeds.last {
                switch type {
                case .morning:
                    lastFeed.morningFedStamp = value ? .now : nil
                    lastFeed.morningFed = value
                case .evening:
                    lastFeed.eveningFedStamp = value ? .now : nil
                    lastFeed.eveningFed = value
                default:
                    break
                }
                if value {
                    lastFeed.feedDate = .now
                }
            }
        }
    }

    func addFeedForToday(value: Bool) {
        let feed = Feed()

        switch pet.selection {
        case .both:
            break
        case .morning:
            feed.morningFedStamp = value ? .now : nil
            feed.morningFed = value
        case .evening:
            feed.eveningFedStamp = value ? .now : nil
            feed.eveningFed = value
        }
        pet.feeds?.append(feed)
        do {
            try modelContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

}

#Preview {
    FeedListView(morningOn: .constant(true), eveningOn: .constant(false), pet: Pet())
}
