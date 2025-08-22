//
//  PetError.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

@MainActor public enum PetError: @preconcurrency LocalizedError {
    case name

    public var errorDescription: String? {
        switch self {
        case .name:
            return String(localized: .nameError)
        }
    }
}
