//
//  DailyFeedChecker.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.08.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData
import SwiftData

class DailyFeedChecker {

    static let shared = DailyFeedChecker()

    func resetLogic(pets: [Pet]) {
        for pet in pets {
            if let feeds = pet.feeds,
               let lastFeed = feeds.last,
               let date = lastFeed.feedDate {
                if !Calendar.current.isDateInToday(date) {
                    let todaysFeed = Feed()
                    todaysFeed.feedDate = .now
                    todaysFeed.eveningFed = false
                    todaysFeed.morningFed = false
                    pet.feeds?.append(todaysFeed)
                }
            }
        }

    }

}
