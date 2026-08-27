//
//  HelloContinueButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.08.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct HelloContinueButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(.welcomeGoButton)
                .foregroundStyle(.accent)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing16)
        }
        .buttonStyle(.glass)
    }
}
