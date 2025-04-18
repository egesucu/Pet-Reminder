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

@Model
public final class Pet {
    @Attribute(.unique) public var name: String
    
    public var birthday: Date
    public var choice: Int
    public var createdAt: Date?
    public var image: Data?
    public var feedSelection: FeedSelection?
    public var type: PetType {
        get { .init(rawValue: petTypeName) ?? .other }
        set { petTypeName = newValue.rawValue }
    }
    private var petTypeName: PetType.RawValue = PetType.other.name
    
    @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?
    
    public init(
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
