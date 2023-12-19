//
//  SetupSteps.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public enum SetupSteps: String, CaseIterable {
  case name, birthday, photo, feedSelection, feedTime

  // MARK: Public

  public var text: String {
    rawValue
  }

  public var index: Int {
    switch self {
    case .name:
      0
    case .birthday:
      1
    case .photo:
      2
    case .feedSelection:
      3
    case .feedTime:
      4
    }
  }
}
