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
    case fivepointfive = "AppIcon-5-5"
    case five = "AppIcon-5-1"

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
        case .fivepointfive:
            return "V5.5"
        case .five:
            return "V5"
        }
    }

    var preview: UIImage {
        UIImage(named: rawValue) ?? UIImage()
    }
}
