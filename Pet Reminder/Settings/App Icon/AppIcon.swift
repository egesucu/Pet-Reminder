//
//  AppIcon.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import UIKit

enum AppIcon: String, CaseIterable, Identifiable {

  case primary = "AppIcon"
  case darkMode = "AppIcon-Dark"
  case fivePointFive = "AppIcon-Old"
  case five = "AppIcon-Oldest"

  // MARK: Internal

  var id: String { rawValue }

  var iconName: String? {
    switch self {
    case .primary:
      nil
    default:
      rawValue
    }
  }

  var description: LocalizedStringKey {
    switch self {
    case .primary:
      "Logo 1(Default)"
    case .darkMode:
      "Logo 2"
    case .fivePointFive:
      "Logo V5.5"
    case .five:
      "Logo V5"
    }
  }

  var preview: UIImage {
    UIImage(named: rawValue) ?? UIImage()
  }
}
