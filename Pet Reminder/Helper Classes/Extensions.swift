//
//  Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

//MARK: - Array
extension Array{
    static var empty : Self { [] }
}

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}

//MARK: - Pet
extension Pet{
    var selection: NotificationSelection {
        get{
            return NotificationSelection(rawValue: self.choice) ?? .both
        }
        set{
            choice = newValue.rawValue
        }
    }
}

//MARK: - LocalizedError
extension IcloudErrorType: LocalizedError {
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
