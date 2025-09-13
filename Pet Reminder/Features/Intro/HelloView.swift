//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CloudKit
import Shared
import SFSafeSymbols

struct HelloView: View {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @State private var navigateToHome = false
    @State private var shouldAnimate = false
    @Environment(NotificationManager.self) private var notificationManager

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text(.welcomeTitle)
                .foregroundStyle(Color.label)
                .font(.title)
                .bold()
            Image(systemSymbol: SFSymbol.pawprintCircleFill)
                .foregroundStyle(Color.label)
                .bold()
                .font(.system(size: 80))
            Text(.welcomeContext)
                .padding(.vertical)
                .foregroundStyle(Color.label)
                .font(.body)
            Spacer()
            HStack {
                Spacer()
                Button(action: goButtonPressed) {
                    Text(.welcomeGoButton)
                        .font(.title)
                        .bold()
                        .padding()
                        .tint(.label)
                }
                .glassEffect(.regular)
                .fullScreenCover(isPresented: $navigateToHome) {
                    HomeManagerView()
                        .environment(notificationManager)
                }
                Spacer()
            }
        }
        .padding()
        .opacity(shouldAnimate ? 1.0 : 0.0)
        .onAppear(perform: animateView)
        .background(
            LinearGradient(
                colors: [
                    .accent,
                    .green.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            ignoresSafeAreaEdges: .all
        )
    }

    @ViewBuilder
    func logoView() -> some View {
        if let logoImage = UIImage(named: "AppIcon") {
            Image(uiImage: logoImage)
                .resizable()
                .frame(width: 200, height: 200)
                .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func goButtonPressed() {
        helloSeen = true
        navigateToHome.toggle()
    }

    private func animateView() {
        withAnimation(.spring().speed(0.2)) {
            shouldAnimate = true
        }
    }
}

#if DEBUG

#Preview {
    HelloView()
        .environment(NotificationManager.shared)
}

#endif
