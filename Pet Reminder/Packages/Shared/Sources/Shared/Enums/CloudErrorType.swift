//
//  CloudError.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

@MainActor public enum CloudError: @preconcurrency LocalizedError {
    case cloudUnavailable
    case cloudNotPresent
    case restricted
    case cantFetchStatus
    case unknownError(String)

    public var errorDescription: String? {
        return switch self {
        case .cloudUnavailable:
            String(localized: .cloudUnavailable)
        case .cloudNotPresent:
            String(localized: .noAccount)
        case .restricted:
            String(localized: .restrictedAccount)
        case .cantFetchStatus:
            String(localized: .cantFetchStatus)
        case .unknownError(let message):
            message
        }
    }

}
