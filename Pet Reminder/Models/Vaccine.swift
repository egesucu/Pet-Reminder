//
//  Vaccine.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model public class Vaccine {
    var date: Date?
    var name: String?

    var pet: Pet?

    init(date: Date? = nil, name: String? = nil, pet: Pet? = nil) {
        self.date = date
        self.name = name
        self.pet = pet
    }

    static let demo = Vaccine(date: .now, name: "Pulvarin")

}
