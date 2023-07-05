//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.06.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model
class Feed {

    var eveningFed: Bool?
    var eveningFedStamp: Date?
    var feedDate: Date?
    var morningFed: Bool?
    var morningFedStamp: Date?

    var pet: Pet?

    init(
        eveningFed: Bool? = nil,
        eveningFedStamp: Date? = nil,
        feedDate: Date? = nil,
        morningFed: Bool? = nil,
        morningFedStamp: Date? = nil
    ) {
        self.eveningFed = eveningFed
        self.eveningFedStamp = eveningFedStamp
        self.feedDate = feedDate
        self.morningFed = morningFed
        self.morningFedStamp = morningFedStamp
    }
}

extension Feed {
    static var demo: Feed {
        let feed = Feed(eveningFed: true,
                               eveningFedStamp: .now.eightPM(),
                               feedDate: .now,
                               morningFed: true,
                               morningFedStamp: .now.eightAM())
        feed.pet = .demo
        return feed
    }
}
