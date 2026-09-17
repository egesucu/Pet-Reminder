//
//  WiggleModifier.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

public struct WiggleModifier: ViewModifier {
    @State private var isWiggling = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    private static func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double.random(in: 0...1000) - 500.0) / 500.0
        return interval + variance * random
    }

    private let rotateAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.14,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)

    private let bounceAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.18,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)

    public func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isEnabled && !reduceMotion && isWiggling ? CGFloat.wiggle : 0))
            .animation(
                reduceMotion || !isEnabled ? nil : rotateAnimation,
                value: isEnabled && !reduceMotion && isWiggling
            )
            .offset(x: 0, y: isEnabled && !reduceMotion && isWiggling ? CGFloat.wiggle : 0)
            .animation(
                reduceMotion || !isEnabled ? nil : bounceAnimation,
                value: isEnabled && !reduceMotion && isWiggling
            )
            .onAppear { isWiggling.toggle() }
    }
}
