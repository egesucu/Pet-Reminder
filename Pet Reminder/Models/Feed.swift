//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import SwiftData

@Model public class Feed {
    var eveningFed = false
    var eveningFedStamp: Date?
    var feedDate: Date?
    var morningFed = false
    var morningFedStamp: Date?
    var pet: Pet?

    public init(
        eveningFed: Bool = false,
        eveningFedStamp: Date? = nil,
        feedDate: Date? = nil,
        morningFed: Bool = false,
        morningFedStamp: Date? = nil
    ) {
        self.eveningFed = eveningFed
        self.eveningFedStamp = eveningFedStamp
        self.feedDate = feedDate
        self.morningFed = morningFed
        self.morningFedStamp = morningFedStamp
    }

}
