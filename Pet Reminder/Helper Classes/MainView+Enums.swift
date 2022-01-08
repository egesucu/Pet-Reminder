//
//  MainView+Enums.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation

enum IcloudError: Error{
    case icloudUnavailable
    case noIcloud
    case restricted
    case cantFetchStatus
    case unknownError(String)
    
}

extension IcloudError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        
        case .icloudUnavailable:
            return NSLocalizedString("cloud_unavailable", comment: "")
        case .noIcloud:
            return NSLocalizedString("no_account", comment: "")
        case .restricted:
            return NSLocalizedString("restricted_account", comment: "")
        case .cantFetchStatus:
            return NSLocalizedString("cant_fetch_status", comment: "")
        case .unknownError(let message):
            return message
        }
        
    }
}
