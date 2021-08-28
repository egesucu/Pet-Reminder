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
            return "iCloud Available"
        case .noIcloud:
            return "No iCloud account"
        case .restricted:
            return "iCloud is restricted"
        case .cantFetchStatus:
            return "iCloud is unavailable at the moment. Please try again later."
        case .unknownError(let message):
            return message
        }
        
    }
}
