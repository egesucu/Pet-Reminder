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

    static func value(status: EKAuthorizationStatus) -> Self {
        return switch status {
        case .notDetermined:
            .notDetermined
        case .restricted:
            .denied
        case .denied:
            .denied
        case .fullAccess:
            .authorized
        case .writeOnly:
            .readOnly
        case .authorized:
            .authorized
        @unknown default:
            .denied
        }
    }
}
