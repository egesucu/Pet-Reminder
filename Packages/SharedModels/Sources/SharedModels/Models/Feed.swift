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
    public var eveningFed = false
    public var eveningFedStamp: Date?
    public var feedDate: Date?
    public var morningFed = false
    public var morningFedStamp: Date?
    public var pet: Pet?

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
