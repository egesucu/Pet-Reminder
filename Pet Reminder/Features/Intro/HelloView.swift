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
import Playgrounds

struct HelloView: View {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @State private var navigateToHome = false
    @State private var shouldAnimate = false
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text("welcome_title")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
            logoView()
            Text("welcome_context")
                .padding(.vertical)
                .foregroundStyle(.white)
                .font(.body)
            Spacer()
            HStack {
                Spacer()
                Button(action: goButtonPressed) {
                    Text(.welcomeGoButton)
                        .font(.title)
                        .bold()
                        .foregroundStyle(.accent)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
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
            Color.accent,
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

#Preview {
    HelloView()
        .environment(NotificationManager.shared)
}


// Broken with Xcode 26 Beta 3
// FIXME: Try this on later betas
//#Playground {
//    let helloString = Strings.helloSeen
//    _ = UserDefaults.standard.bool(forKey: helloString)
//}
