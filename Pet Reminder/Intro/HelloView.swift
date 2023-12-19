//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import CloudKit
import SwiftUI

struct HelloView: View {

  // MARK: Internal

  @AppStorage(Strings.tintColor) var tintColor = Color.accent
  @AppStorage(Strings.helloSeen) var helloSeen = false

  var body: some View {
    VStack(alignment: .center, spacing: 20) {
      Text("welcome_title")
        .font(.title)
      logoView()
      Text("welcome_context")
        .padding(.vertical)
        .font(.body)
      Spacer()
      HStack {
        Spacer()
        Button(action: goButtonPressed) {
          Text("welcome_go_button")
            .font(.title)
            .foregroundStyle(.white)
        }
        .padding()
        .background(tintColor)
        .clipShape(.rect(cornerRadius: 25.0))
        .shadow(radius: 3)
        .fullScreenCover(isPresented: $navigateToHome) {
          HomeManagerView()
        }
        Spacer()
      }
    }
    .padding()
    .opacity(shouldAnimate ? 1.0 : 0.0)
    .onAppear(perform: animateView)
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

  // MARK: Private

  @State private var navigateToHome = false
  @State private var shouldAnimate = false
  @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

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
    .environment(NotificationManager())
}
