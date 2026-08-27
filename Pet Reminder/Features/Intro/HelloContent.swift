//
//  HelloContent.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.08.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct HelloContent: View {
    var body: some View {
        VStack(spacing: .spacing20) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: .icon64, weight: .semibold))
                .foregroundStyle(.accent)
                .frame(width: .symbolBackground, height: .symbolBackground)
                .background(.accent.opacity(0.12), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.accent.opacity(0.18), lineWidth: 1)
                }
                .accessibilityHidden(true)

            VStack(spacing: .spacing12) {
                Text(.welcomeTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(.welcomeContext)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(.spacing4)
            }
        }
    }
}

private extension CGFloat {
    static let icon64: Self = 64
    static let symbolBackground: Self = 152
}
