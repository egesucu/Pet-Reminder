//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import SwiftData

@Model final class Pet: @unchecked Sendable {
    var id: UUID = UUID()
    var birthday: Date = Date()
    var choice: Int = 0
    var createdAt: Date?
    var image: Data?
    var feedSelection: FeedSelection?
    var name: String = ""
    var type: PetType = PetType.dog
    
    @Relationship(inverse: \Feed.pet) var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) var vaccines: [Vaccine]?
    
    init(
        id: UUID = UUID(),
        birthday: Date = Date(),
        name: String,
        choice: Int = 0,
        createdAt: Date? = nil,
        feedSelection: FeedSelection? = nil,
        image: Data? = nil,
        feeds: [Feed]? = nil,
        vaccines: [Vaccine]? = nil,
        type: PetType = .dog
    ) {
        self.id = id
        self.birthday = birthday
        self.name = name
        self.choice = choice
        self.createdAt = createdAt
        self.image = image
        self.feedSelection = feedSelection
        self.feeds = feeds
        self.vaccines = vaccines
        self.type = type
    }
}
