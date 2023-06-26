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
            return Strings.cloudUnavailable
        case .noIcloud:
            return Strings.noAccount
        case .restricted:
            return Strings.restrictedAccount
        case .cantFetchStatus:
            return Strings.cantFetchStatus
        case .unknownError(let message):
            return message
        }
    }

}
