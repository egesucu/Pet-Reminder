//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model public class Pet {
    var name: String = ""

    var birthday: Date = Date()
    var choice: Int64 = 0
    var createdAt: Date?
    var eveningFed: Bool?
    var eveningTime: Date?

    var image: Data?
    var morningFed: Bool?
    var morningTime: Date?

    @Relationship(inverse: \Feed.pet) var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) var vaccines: [Vaccine]?

    init(
        choice: Int64 = 0,
        createdAt: Date? = nil,
        eveningFed: Bool? = nil,
        eveningTime: Date? = nil,
        image: Data? = nil,
        morningFed: Bool? = nil,
        morningTime: Date? = nil,
        name: String = "",
        feeds: [Feed]? = nil,
        vaccines: [Vaccine]? = nil
    ) {
        self.choice = choice
        self.createdAt = createdAt
        self.eveningFed = eveningFed
        self.eveningTime = eveningTime
        self.image = image
        self.morningFed = morningFed
        self.morningTime = morningTime
        self.name = name
        self.feeds = feeds
        self.vaccines = vaccines
    }

    static let demo = Pet(
        choice: FeedTimeSelection.both.rawValue,
        createdAt: .now,
        eveningFed: false,
        eveningTime: nil,
        image: nil,
        morningFed: false,
        morningTime: nil,
        name: "Viski",
        feeds: [.demo],
        vaccines: [.demo, .demo]
    )

}

// MARK: - Pet Extension
extension Pet {
    var selection: FeedTimeSelection {
        get {
            return FeedTimeSelection(rawValue: self.choice) ?? .both
        }
        set {
            choice = newValue.rawValue
        }
    }
}
