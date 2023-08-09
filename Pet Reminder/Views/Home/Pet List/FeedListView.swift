//
//  FeedListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct FeedListView: View {

    @Binding var morningOn: Bool
    @Binding var eveningOn: Bool
    @Environment(\.managedObjectContext) var viewContext

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
        if let feedSet = pet.feeds?.allObjects as? [Feed] {
            return feedSet.filter({ feed in
                Calendar.current.isDateInToday(feed.feedDate ?? .now) })
        }
        return []
    }

    func updateFeed(type: FeedTimeSelection, value: Bool) {

        if todaysFeeds.isEmpty {
            addFeedForToday(viewContext: viewContext, value: value)
        } else {
            if let feeds = pet.feeds,
               let feedSet = feeds.allObjects as? [Feed],
               let lastFeed = feedSet.last {
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

    func addFeedForToday(viewContext: NSManagedObjectContext, value: Bool) {
        let feed = Feed(context: viewContext)

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
        if var feeds = pet.feeds?.allObjects as? [Feed] {
            feeds.append(feed)
        }
        PersistenceController.shared.save()
    }

}

#Preview {
    FeedListView(morningOn: .constant(true), eveningOn: .constant(false))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
