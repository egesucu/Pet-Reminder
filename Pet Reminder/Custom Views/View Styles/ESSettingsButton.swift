//
//  ESSettingsButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 8.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct ESSettingsButton: View {
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accent)

    var body: some View {
        Button("open_settings", action: openSettings)
            .buttonStyle(.bordered)
            .tint(tintColor.color)
    }

    private func openSettings() {
        @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accent)
    }
}

#Preview {
    ESSettingsButton()
}
