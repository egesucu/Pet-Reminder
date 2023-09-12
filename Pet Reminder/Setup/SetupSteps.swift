//
//  SetupSteps.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation

public enum SetupSteps: String, CaseIterable {
    public var text: String {
        return self.rawValue
    }
    case name, birthday, photo, feedSelection, feedTime

    public var index: Int {
        switch self {
        case .name:
            return 0
        case .birthday:
            return 1
        case .photo:
            return 2
        case .feedSelection:
            return 3
        case .feedTime:
            return 4
        }
    }
}
