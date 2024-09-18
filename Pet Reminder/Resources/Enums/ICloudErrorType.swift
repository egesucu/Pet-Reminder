//
//  ICloudError.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum IcloudErrorType: LocalizedError {
    case icloudUnavailable
    case noIcloud
    case restricted
    case cantFetchStatus
    case unknownError(String)

    var errorDescription: String? {
        return switch self {
        case .icloudUnavailable:
            String(localized: "cloud_unavailable")
        case .noIcloud:
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
