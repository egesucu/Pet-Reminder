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

@Model public final class Pet: @unchecked Sendable {
    public var id: UUID = UUID()
    public var birthday: Date = Date()
    public var choice: Int = 0
    public var createdAt: Date?
    public var image: Data?
    public var feedSelection: FeedSelection?
    public var name: String = ""
    
    @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?
    
    public init(
        id: UUID = UUID(),
        birthday: Date = Date(),
        name: String,
        choice: Int = 0,
        createdAt: Date? = nil,
        feedSelection: FeedSelection? = nil,
        image: Data? = nil,
        feeds: [Feed]? = nil,
        vaccines: [Vaccine]? = nil
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
    }
}
