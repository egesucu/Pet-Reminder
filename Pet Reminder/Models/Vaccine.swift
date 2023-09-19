//
//  Vaccine.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model public class Vaccine {
    var date = Date.now
    var name = ""
    var pet: Pet?

    public init() { }

}
