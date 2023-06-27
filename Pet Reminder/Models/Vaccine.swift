//
//  Vaccine.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.06.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model
class Vaccine: Identifiable {
    var date: Date?
    var name: String?

    @Attribute(.unique)
    public var id = UUID()

    var pet: Pet?

    init(date: Date? = nil, name: String? = nil) {
        self.date = date
        self.name = name
    }
}

extension Vaccine {
    static var demo: Vaccine {
        let vaccine = Vaccine(date: .now, name: "Pulvarin")
        vaccine.pet = .demo
        return vaccine
    }

}
