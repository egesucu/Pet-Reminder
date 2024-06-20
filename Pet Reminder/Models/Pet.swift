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

@Model final class Pet: Sendable {
    var id: UUID
    var birthday: Date
    var choice: Int
    var createdAt: Date?
    var image: Data?
    var feedSelection: FeedSelection?
    var name: String

    @Relationship(inverse: \Feed.pet) var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) var vaccines: [Vaccine]?

    init(
        id: UUID = UUID(),
        birthday: Date,
        name: String,
        choice: Int,
        createdAt: Date?,
        feedSelection: FeedSelection?,
        image: Data?
    ) {
        self.id = id
        self.birthday = birthday
        self.name = name
        self.choice = choice
        self.createdAt = createdAt
        self.image = image
        self.feedSelection = feedSelection
    }

}
