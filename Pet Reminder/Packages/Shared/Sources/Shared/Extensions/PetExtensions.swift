//
//  PetExtensions.swift
//  Shared
//
//  Created by Ege Sucu on 26.06.2025.
//

import Foundation
@preconcurrency import SwiftData
import UIKit.UIImage

public extension Pet {
    static var preview: Pet {
        let firstPet = previews.first ?? .init(
            birthday: .now,
            name: "",
            createdAt: nil,
            feedSelection: .both,
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
