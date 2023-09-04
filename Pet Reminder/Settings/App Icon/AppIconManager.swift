//
//  AppIconManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import Observation
import UIKit

@Observable
class AppIconManager {
    private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName,
            let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.iconName else {
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                print("Updating icon to \(String(describing: icon.iconName)) failed.")
                selectedAppIcon = previousAppIcon
            }

        }

    }
}
