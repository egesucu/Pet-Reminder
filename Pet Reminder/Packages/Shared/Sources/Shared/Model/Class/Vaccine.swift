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

@Model
public class Vaccine {
    public var date: Date = Date.now
    public var name: String = String.empty
    public var pet: Pet?

    public init(
        date: Date = Date.now,
        name: String = .empty
    ) {
        self.date = date
        self.name = name
    }
}
