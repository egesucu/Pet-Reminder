//
//  ESSettingsButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 8.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

struct ESSettingsButton: View {
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    public var body: some View {
        Button("open_settings", action: openSettings)
            .buttonStyle(.bordered)
            .tint(tintColor.color)
    }

    private func openSettings() {
        @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)
    }
}

#Preview {
    ESSettingsButton()
}
