//
//  Hello.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CloudKit
import Shared

struct Hello: View {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @State private var shouldAnimate = false
    @Environment(\.notification) private var notificationManager: NotificationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .spacing100) {
                Text(.welcomeTitle)
                    .foregroundStyle(Color.label)
                    .font(.title)
                    .bold()
                Image(systemName: "pawprint.circle.fill")
                    .foregroundStyle(Color.label)
                    .bold()
                    .font(.system(size: .icon120))
                Text(.welcomeContext)
                    .foregroundStyle(Color.label)
                    .font(.body)
                Spacer()
            }
            .padding(.horizontal, .spacing12)
            .opacity(shouldAnimate ? 1.0 : 0.0)
            .onAppear(perform: animateView)
            
            Button(action: goButtonPressed) {
                Text(.welcomeGoButton)
                    .font(.title)
                    .foregroundStyle(Color.label)
                    .bold()
                    .padding(.horizontal, .spacing20)
                    .padding(.vertical, .spacing16)
            }
            .buttonStyle(.glass)
            
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    .accent.opacity(0.6),
                    .green.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottom
            ),
            ignoresSafeAreaEdges: .all
        )
    }
}

private extension Hello {
    func goButtonPressed() {
        helloSeen = true
    }

    func animateView() {
        withAnimation(.spring().speed(0.2)) {
            shouldAnimate = true
        }
    }
}

private extension CGFloat {
    static let spacing100: Self = 100
    static let icon120: Self = 120
}

#if DEBUG

#Preview("English") {
    Hello()
        .notification(NotificationManager.shared)
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("German") {
    Hello()
        .notification(NotificationManager.shared)
        .environment(\.locale, .init(identifier: "de"))
}

#Preview("Spanish") {
    Hello()
        .notification(NotificationManager.shared)
        .environment(\.locale, .init(identifier: "es"))
}

#Preview("Italian") {
    Hello()
        .notification(NotificationManager.shared)
        .environment(\.locale, .init(identifier: "it"))
}

#Preview("Turkish") {
    Hello()
        .notification(NotificationManager.shared)
        .environment(\.locale, .init(identifier: "tr"))
}

#endif
