//
//  HelloBottomShape.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.08.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloBottomShape: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFloating = false

    var body: some View {
        ZStack(alignment: .bottom) {
            OnboardingWave(leadingHeight: 0.08, centerDepth: 0.58, trailingHeight: 0.24)
                .fill(
                    LinearGradient(
                        colors: [
                            .accent.opacity(0.07),
                            .accent.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(x: 1.12, anchor: .center)
                .offset(x: isFloating ? 8 : -8)

            OnboardingWave(leadingHeight: 0.24, centerDepth: 0.48, trailingHeight: 0.08)
                .fill(
                    LinearGradient(
                        colors: [
                            .mint.opacity(0.18),
                            .accent.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(x: 1.12, anchor: .center)
                .offset(x: isFloating ? -10 : 6, y: 38)

            OnboardingWave(leadingHeight: 0.34, centerDepth: 0.52, trailingHeight: 0.22)
                .fill(.accent.opacity(0.08))
                .scaleEffect(x: 1.12, anchor: .center)
                .offset(y: 90)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.mint.opacity(0.32), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 18)
                .offset(x: isFloating ? 120 : 90, y: 90)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.accent.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 24)
                .offset(x: isFloating ? -130 : -100, y: 120)
        }
        .frame(height: .bottomShapeHeight)
        .clipped()
        .compositingGroup()
        .ignoresSafeArea(edges: .bottom)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }

            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
}

private nonisolated struct OnboardingWave: Shape {
    let leadingHeight: CGFloat
    let centerDepth: CGFloat
    let trailingHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.height * leadingHeight))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * trailingHeight),
            control1: CGPoint(x: rect.width * 0.28, y: rect.height * centerDepth),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height * centerDepth)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

private extension CGFloat {
    static let bottomShapeHeight: Self = 330
}
