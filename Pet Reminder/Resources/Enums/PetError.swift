//
//  PetError.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum PetError: LocalizedError {
    case name

    var errorDescription: String? {
        if self == .name {
            return String(localized: "name_error")
        } else {
            return "Unknown error"
        }
    }
}
