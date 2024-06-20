//
//  Vaccine.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import SwiftData

@Model class Vaccine {
    var date = Date.now
    var name = ""
    var pet: Pet?

    init(
        date: Foundation.Date = Date.now,
        name: String = ""
    ) {
        self.date = date
        self.name = name
    }

}
