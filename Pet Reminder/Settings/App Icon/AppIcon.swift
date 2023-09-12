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

    var id: String { rawValue }

    var iconName: String? {
        switch self {
        case .primary:
            return nil
        case .darkMode:
            return rawValue
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .primary:
            return "Logo 1(Default)"
        case .darkMode:
            return "Logo 2"
        }
    }

    var preview: UIImage {
        UIImage(named: rawValue) ?? UIImage()
    }
}
