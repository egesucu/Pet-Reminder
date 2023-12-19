//
//  EventAuthenticationStatus.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import EventKit
import Foundation

enum EventAuthenticationStatus: String {
  case authorized
  case readOnly
  case denied
  case notDetermined

  // MARK: Internal

  static func value(status: EKAuthorizationStatus) -> Self {
    switch status {
    case .notDetermined:
      return .notDetermined
    case .restricted:
      return .denied
    case .denied:
      return .denied
    case .fullAccess:
      return .authorized
    case .writeOnly:
      return .readOnly
    case .authorized:
      return .authorized
    @unknown default:
      return .denied
    }
  }
}
