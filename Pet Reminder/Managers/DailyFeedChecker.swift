//
//  DailyFeedChecker.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.08.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

class DailyFeedChecker {

    static let shared = DailyFeedChecker()

    func resetLogic(pets: FetchedResults<Pet>, context: NSManagedObjectContext) {
        for pet in pets {
            if let feedSet = pet.feeds,
               let feeds = feedSet.allObjects as? [Feed],
               let lastFeed = feeds.last,
               let date = lastFeed.feedDate {
                if !Calendar.current.isDateInToday(date) {
                    let todaysFeed = Feed(context: context)
                    todaysFeed.feedDate = .now
                    todaysFeed.eveningFed = false
                    todaysFeed.morningFed = false
                    pet.addToFeeds(todaysFeed)
                }
            }
        }
        do {
            try context.save()
        } catch {
            print(error)
        }

    }

}
