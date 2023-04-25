//
//  ICloudError.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum IcloudErrorType: Error{
    case icloudUnavailable
    case noIcloud
    case restricted
    case cantFetchStatus
    case unknownError(String)
    
}
