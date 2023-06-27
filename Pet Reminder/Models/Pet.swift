//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.06.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import SwiftData
import UIKit

@Model
class Pet {
    @Attribute(.unique)
    var id = UUID()

    var birthday: Date?
    // swiftlint: disable todo
    // Figure the custom types(enums) in swift data,
    // FIXME: currently it has a problem https://developer.apple.com/forums/thread/731538
    // swiftlint: enable todo
    // var choice: NotificationSelection = .both
    var createdAt: Date?
    var eveningFed: Bool?
    var eveningTime: Date?
    var image: Data?
    var morningFed: Bool?
    var morningTime: Date?
    var name: String?

    @Relationship(.cascade, inverse: \Feed.pet)
    var feeds: [Feed]?
    @Relationship(.cascade, inverse: \Vaccine.pet)
    var vaccines: [Vaccine]?

    init(
        birthday: Date? = nil,
        createdAt: Date? = nil,
        eveningFed: Bool? = nil,
        eveningTime: Date? = nil,
        image: Data? = nil,
        morningFed: Bool? = nil,
        morningTime: Date? = nil,
        name: String? = nil
    ) {
        self.birthday = birthday
        // self.choice = choice
        self.createdAt = createdAt
        self.eveningFed = eveningFed
        self.eveningTime = eveningTime
        self.image = image
        self.morningFed = morningFed
        self.morningTime = morningTime
        self.name = name
    }

}

extension Pet {
    static var demo: Pet {
        Pet(birthday: .now,
//            choice: .both,
            createdAt: .now,
            eveningFed: false,
            eveningTime: .now.eightPM(),
            image: UIImage(named: "default-animal")?.jpegData(compressionQuality: 0.8),
            morningFed: true,
            morningTime: .now.eightAM(),
            name: Strings.viski)
    }
}
