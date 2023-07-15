//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model public class Feed {
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
        morningFedStamp: Date? = nil,
        pet: Pet? = nil
    ) {
        self.eveningFed = eveningFed
        self.eveningFedStamp = eveningFedStamp
        self.feedDate = feedDate
        self.morningFed = morningFed
        self.morningFedStamp = morningFedStamp
        self.pet = pet
    }

    static let demo = Feed(eveningFed: false,
                           eveningFedStamp: nil,
                           feedDate: .now,
                           morningFed: true,
                           morningFedStamp: .now)
}
