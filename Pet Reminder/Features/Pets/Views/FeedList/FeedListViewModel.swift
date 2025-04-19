//
//  FeedListViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import Observation
import SwiftData
import OSLog
import Shared

@MainActor
@Observable
class FeedListViewModel {
    
    var morningOn = false
    var eveningOn = false
    
    init(morningOn: Bool = false, eveningOn: Bool = false) {
        self.morningOn = morningOn
        self.eveningOn = eveningOn
    }

    func todaysFeeds(pet: Pet?) -> [Feed] {
        guard let pet else { return [] }
        return pet
            .feeds?
            .filter { Calendar.current.isDateInToday($0.feedDate ?? .now) } ?? []
    }

    @MainActor
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
    }

    @MainActor
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
