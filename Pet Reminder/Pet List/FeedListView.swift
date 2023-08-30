//
//  FeedListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import CoreData
import OSLog

struct FeedListView: View {

    @State private var morningOn = false
    @State private var eveningOn = false
    @Environment(\.managedObjectContext) var viewContext

    @Binding var pet: Pet?

    let feedback = UINotificationFeedbackGenerator()

    var body: some View {
        HStack(spacing: 30) {
            if let pet {
                switch pet.selection {
                case .morning:
                    MorningCheckboxView(morningOn: $morningOn)
                        .onChange(of: morningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Morning Changed, new value: \(morningOn), pet: \(pet.name ?? "")")
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .morning, value: morningOn)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Morning Tapped, pet: \(pet.name ?? "")")
                            morningOn.toggle()
                        }
                case .evening:
                    EveningCheckboxView(eveningOn: $eveningOn)
                        .onChange(of: eveningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Evening Changed, new value: \(eveningOn), pet: \(pet.name ?? "")")
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .evening, value: eveningOn)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Evening Tapped, pet: \(pet.name ?? "")")
                            eveningOn.toggle()
                        }
                case .both:
                    MorningCheckboxView(morningOn: $morningOn)
                        .onChange(of: morningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Morning Changed, new value: \(morningOn), pet: \(pet.name ?? "")")
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .morning, value: morningOn)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Morning Tapped, pet: \(pet.name ?? "")")
                            morningOn.toggle()
                        }
                    EveningCheckboxView(eveningOn: $eveningOn)
                        .onChange(of: eveningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Evening Changed, new value: \(eveningOn), pet: \(pet.name ?? "")")
                            feedback.notificationOccurred(.success)
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .evening, value: eveningOn)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Evening Tapped, pet: \(pet.name ?? "")")
                            eveningOn.toggle()
                        }
                }
            }

        }
        .onAppear(perform: getLatestFeed)
        .onChange(of: pet, getLatestFeed)
    }

    var todaysFeeds: [Feed] {
        if let pet,
           let feedSet = pet.feeds,
           let feeds = feedSet.allObjects as? [Feed] {
            return feeds.filter { feed in
                Calendar.current.isDateInToday(feed.feedDate ?? .now)
            }
        }
        return []
    }

    func updateFeed(type: FeedTimeSelection, value: Bool) {

        if todaysFeeds.isEmpty {
            addFeedForToday(viewContext: viewContext, value: value)
        } else {
            if let pet,
                let feeds = pet.feeds,
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

    func getLatestFeed() {
        if let pet,
           let feeds = pet.feeds?.allObjects as? [Feed] {
            if let lastFeed = feeds.last {
                if let date = lastFeed.feedDate {
                    if Calendar.current.isDateInToday(date) {
                        // We have a feed.
                        morningOn = lastFeed.morningFed
                        eveningOn = lastFeed.eveningFed
                    } else {
                        morningOn = false
                        eveningOn = false
                    }
                }
            }
        } else {
            morningOn = false
            eveningOn = false
        }
    }

    func addFeedForToday(viewContext: NSManagedObjectContext, value: Bool) {
        let feed = Feed(context: viewContext)

        if let pet {
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
            pet.addToFeeds(feed)
            PersistenceController.shared.save()
        }

    }

}

#Preview {
    let preview = PersistenceController.preview.container.viewContext
    return FeedListView(pet: .constant(Pet(context: preview)))
        .environment(\.managedObjectContext, preview)
}
