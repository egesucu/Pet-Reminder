//
//  CloudError.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public enum CloudError: LocalizedError {
    case cloudUnavailable
    case cloudNotPresent
    case restricted
    case cantFetchStatus
    case unknownError(String)

    public var errorDescription: String? {
        return switch self {
        case .cloudUnavailable:
            String(localized: "cloud_unavailable")
        case .cloudNotPresent:
            String(localized: "no_account")
        case .restricted:
            String(localized: "restricted_account")
        case .cantFetchStatus:
            String(localized: "cant_fetch_status")
        case .unknownError(let message):
            message
        }
    }

}
