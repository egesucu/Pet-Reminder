//
//  AppIcon.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import UIKit
import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {

    case primary = "AppIcon"
    case darkMode = "AppIcon-Dark"
    case fivePointFive = "AppIcon-Old"
    case five = "AppIcon-Oldest"

    var id: String { rawValue }

    var iconName: String? {
        switch self {
        case .primary:
            return nil
        default:
            return rawValue
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .primary:
            return "Logo 1(Default)"
        case .darkMode:
            return "Logo 2"
        case .fivePointFive:
            return "Logo V5.5"
        case .five:
            return "Logo V5"
        }
    }

    var preview: UIImage {
        UIImage(named: rawValue) ?? UIImage()
    }
}
