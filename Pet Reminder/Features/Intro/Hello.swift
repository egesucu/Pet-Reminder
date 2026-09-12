//
//  Hello.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct Hello: View {
    @AppStorage(Strings.helloSeen) private var helloSeen = false
    @State private var shouldAnimate = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            HelloBottomShape()

            VStack(spacing: 0) {
                Spacer()
                HelloContent()
                Spacer()
                HelloContinueButton(action: returnHome)
            }
            .padding(.horizontal, .spacing20)
            .padding(.bottom, .spacing20)
            .opacity(shouldAnimate ? 1 : 0)
            .offset(y: shouldAnimate ? 0 : .spacing20)
        }
        .onAppear(perform: animateView)
    }
}

private extension Hello {
    func returnHome() {
        helloSeen = true
    }

    func animateView() {
        withAnimation(.smooth(duration: 0.7)) {
            shouldAnimate = true
        }
    }
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
