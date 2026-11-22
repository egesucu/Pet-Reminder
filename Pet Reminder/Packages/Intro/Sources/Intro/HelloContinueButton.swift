//
//  HelloContinueButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.08.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI

struct HelloContinueButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(SharedStrings.welcomeGoButton)
                .foregroundStyle(.primary)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing16)
        }
        .buttonStyle(.glass)
    }
}
