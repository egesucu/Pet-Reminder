//
//  SettingsButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 8.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI


public struct SettingsButton: View {
    
    public init() {}

    public var body: some View {
        Button("open_settings", action: openSettings)
            .buttonStyle(.bordered)
            .tint(.accent)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsButton()
}
