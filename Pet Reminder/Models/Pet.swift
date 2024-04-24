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

@Model public class Pet {
    public var id = UUID()
    var birthday = Date()
    var choice = 0
    var createdAt: Date?
    var eveningFed = false
    var eveningTime: Date?
    var image: Data?
    var morningFed = false
    var morningTime: Date?
    var name = ""

    @Relationship(inverse: \Feed.pet) var feeds: [Feed]?
    @Relationship(inverse: \Vaccine.pet) var vaccines: [Vaccine]?

    public init(
        birthday: Date = Date(),
        name: String = "",
        choice: Int = 0,
        createdAt: Date? = nil,
        eveningFed: Bool = false,
        eveningTime: Date? = nil,
        image: Data? = nil,
        morningFed: Bool = false,
        morningTime: Date? = nil
    ) {
        self.birthday = birthday
        self.name = name
        self.choice = choice
        self.createdAt = createdAt
        self.eveningTime = eveningTime
        self.eveningFed = eveningFed
        self.morningTime = morningTime
        self.morningFed = morningFed
        self.image = image
    }

}
