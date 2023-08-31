//
//  FeedListViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import Observation
import CoreData

@Observable
class FeedListViewModel {

    var morningOn = false
    var eveningOn = false

    func updateFeed(pet: Pet?, feeds: [Feed], type: FeedTimeSelection, viewContext: NSManagedObjectContext) {
        if feeds.isEmpty {
            addFeedForToday(pet: pet, viewContext: viewContext)
        } else {
            if let pet,
               let feeds = pet.feeds,
               let feedSet = feeds.allObjects as? [Feed],
               let lastFeed = feedSet.last {
                switch type {
                case .morning:
                    lastFeed.morningFedStamp = morningOn ? .now : nil
                    lastFeed.morningFed = morningOn
                case .evening:
                    lastFeed.eveningFedStamp = eveningOn ? .now : nil
                    lastFeed.eveningFed = eveningOn
                default:
                    break
                }
                lastFeed.feedDate = .now
            }
        }
    }

    func getLatestFeed(pet: Pet?) async {
        if let pet,
           let feedSet = pet.feeds,
           let feeds = feedSet.allObjects as? [Feed] {
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

    func addFeedForToday(pet: Pet?, viewContext: NSManagedObjectContext) {
        let feed = Feed(context: viewContext)

        if let pet {
            switch pet.selection {
            case .both:
                break
            case .morning:
                feed.morningFedStamp = morningOn ? .now : nil
                feed.morningFed = morningOn
            case .evening:
                feed.eveningFedStamp = eveningOn ? .now : nil
                feed.eveningFed = eveningOn
            }
            pet.addToFeeds(feed)
            PersistenceController.shared.save()
        }

    }

}
