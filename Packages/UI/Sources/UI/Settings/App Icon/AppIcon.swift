//
//  AppIcon.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import UIKit
import SwiftUI

public enum AppIcon: String, CaseIterable, Identifiable {

    case primary = "AppIcon"
    case darkMode = "AppIcon-Dark"
    case fivePointFive = "AppIcon-Old"
    case five = "AppIcon-Oldest"

    public var id: String { rawValue }

    public var iconName: String? {
        switch self {
        case .primary:
            return nil
        default:
            return rawValue
        }
    }

    public var description: LocalizedStringKey {
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

    public var preview: UIImage {
        UIImage(named: rawValue, in: .module, compatibleWith: nil) ?? UIImage()
    }
}
