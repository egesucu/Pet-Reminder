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
        switch self {
        case .icloudUnavailable:
            return String(localized: "cloud_unavailable")
        case .noIcloud:
            return String(localized: "no_acount")
        case .restricted:
            return String(localized: "restricted_account")
        case .cantFetchStatus:
            return String(localized: "cant_fetch_status")
        case .unknownError(let message):
            return message
        }
    }

}
