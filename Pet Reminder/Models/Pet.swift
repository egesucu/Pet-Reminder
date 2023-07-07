//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import SwiftData
import UIKit

@Model
class Pet {
    var birthday: Date?
    var selection: String?
    var createdAt: Date?
    var eveningFed: Bool?
    var eveningTime: Date?
    var image: Data?
    var morningFed: Bool?
    var morningTime: Date?
    var name: String = ""

    @Relationship(.cascade, inverse: \Feed.pet)
    var feeds: [Feed]?
    @Relationship(.cascade, inverse: \Vaccine.pet)
    var vaccines: [Vaccine]?

    init(
        birthday: Date? = nil,
        selection: String? = nil,
        createdAt: Date? = nil,
        eveningFed: Bool? = nil,
        eveningTime: Date? = nil,
        image: Data? = nil,
        morningFed: Bool? = nil,
        morningTime: Date? = nil,
        name: String = ""
    ) {
        self.birthday = birthday
        self.selection = selection
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
    var choice: FeedTimeSelection {
        get {
            return FeedTimeSelection(rawValue: self.selection ?? "") ?? .both
        }
        set {
            selection = newValue.rawValue
        }
    }

    static var demo: Pet {
        Pet(birthday: .now,
            createdAt: .now,
            eveningFed: false,
            eveningTime: .now.eightPM(),
            image: convertDefaulImage(),
            morningFed: true,
            morningTime: .now.eightAM(),
            name: Strings.viski)
    }

    static func convertDefaulImage() -> Data {
        guard let image = UIImage(named: "default-animal") else { return .init() }
        return image.jpegData(compressionQuality: 0.8) ?? .init()
    }
}
