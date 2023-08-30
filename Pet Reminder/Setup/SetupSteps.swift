//
//  SetupSteps.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation

enum SetupSteps: String, CaseIterable {
    var text: String {
        return self.rawValue
    }
    case name, birthday, photo, feedSelection, feedTime
}
