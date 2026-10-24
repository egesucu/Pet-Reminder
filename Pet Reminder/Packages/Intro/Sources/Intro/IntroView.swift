//
//  IntroView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI

@MainActor
public struct IntroView: View {
    private let onContinue: @MainActor () -> Void

    @State private var shouldAnimate = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    public init(onContinue: @escaping @MainActor () -> Void) {
        self.onContinue = onContinue
    }

    public var body: some View {
        ScrollView {
            HelloContent()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, .spacing20)
                .padding(.vertical, verticalSizeClass == .compact ? .spacing12 : .spacing40)
        }
        .scrollIndicators(.hidden)
        .opacity(shouldAnimate ? 1 : 0)
        .offset(y: shouldAnimate ? 0 : .spacing20)
        .safeAreaInset(edge: .bottom) {
            HelloContinueButton(action: onContinue)
                .padding(.horizontal, .spacing20)
                .padding(.bottom, .spacing20)
        }
        .background {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Color(uiColor: .systemBackground)

                    HelloBottomShape()
                        .frame(height: geometry.size.height * 0.28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
        .onAppear(perform: animateView)
    }
}

private extension IntroView {
    func animateView() {
        withAnimation(.smooth(duration: 0.7)) {
            shouldAnimate = true
        }
    }
}

#if DEBUG

#Preview("English") {
    IntroView(onContinue: {})
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("German") {
    IntroView(onContinue: {})
        .environment(\.locale, .init(identifier: "de"))
}

#Preview("Spanish") {
    IntroView(onContinue: {})
        .environment(\.locale, .init(identifier: "es"))
}

#Preview("Italian") {
    IntroView(onContinue: {})
        .environment(\.locale, .init(identifier: "it"))
}

#Preview("Turkish") {
    IntroView(onContinue: {})
        .environment(\.locale, .init(identifier: "tr"))
}

#endif
