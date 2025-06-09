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
import UIKit.UIImage

@Model
public final class Pet {
    public var name: String = ""
    public var birthday: Date = Date.now
    public var choice: Int = 0
    public var createdAt: Date?
    public var image: Data?
    public var feedSelection: FeedSelection?
    private var petTypeName: PetType.RawValue = PetType.other.rawValue
    
    @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?
    
    public init(
        birthday: Date = Date(),
        name: String = "",
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

public extension Pet {
    var type: PetType {
        get { .init(rawValue: petTypeName) ?? .other }
        set { petTypeName = newValue.rawValue }
    }
    
    static var preview: Pet {
        let firstPet = previews.first ?? .init(
            birthday: .now,
            name: "",
            choice: 0,
            createdAt: nil,
            feedSelection: nil,
            image: nil
        )
        return firstPet
    }

    static var previews: [Pet] {
        var pets: [Pet] = []
        Strings.demoPets.forEach { petName in
            let randomType = PetType.allCases.randomElement() ?? .dog
            let pet = Pet(
                birthday: .randomDate(),
                name: petName,
                choice: [0, 1, 2].randomElement() ?? 0,
                createdAt: .randomDate(),
                feedSelection: .both,
                image: randomType.uiImage.jpegData(compressionQuality: 0.8),
                type: randomType
            )
            pet.feeds = Feed.previews
            pet.vaccines = Vaccine.previews
            pets.append(pet)
        }
        return pets
    }
}
