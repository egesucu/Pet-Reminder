//
//  PetError.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public enum PetError: LocalizedError {
    case name

    nonisolated public var errorDescription: String? {
        switch self {
        case .name:
            return String(localized: "name_error")
        }
    }
}
