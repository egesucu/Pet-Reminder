//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import UIKit

public extension Pet {

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
            let pet = Pet(
                birthday: .randomDate(),
                name: petName,
                choice: [0, 1, 2].randomElement() ?? 0,
                createdAt: .randomDate(),
                feedSelection: .both, 
                image: UIImage(named: "default-animal")?
                    .jpegData(compressionQuality: 0.8)
            )
            pet.feeds = Feed.previews
            pet.vaccines = Vaccine.previews
            pets.append(pet)
        }
        return pets
    }
}
