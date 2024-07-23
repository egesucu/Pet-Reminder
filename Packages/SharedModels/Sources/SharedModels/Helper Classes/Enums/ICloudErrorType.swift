//
//  ICloudError.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public enum IcloudErrorType: LocalizedError {
    case icloudUnavailable
    case noIcloud
    case restricted
    case cantFetchStatus
    case unknownError(String)

    public var errorDescription: String? {
        switch self {
        case .icloudUnavailable:
            return String(localized: "cloud_unavailable", bundle: .module)
        case .noIcloud:
            return String(localized: "no_account", bundle: .module)
        case .restricted:
            return String(localized: "restricted_account", bundle: .module)
        case .cantFetchStatus:
            return String(localized: "cant_fetch_status", bundle: .module)
        case .unknownError(let message):
            return message
        }
    }

}
