//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    @AppStorage(Strings.tintColor) var tintColor = Color.green
    @AppStorage("seenHello") var helloSeen = false
    @State private var navigateToHome = false
    @State private var buttonTimer: Timer?
    @State private var imageTimer: Timer?
    @State private var buttonOpacity = 0.0
    @State private var imageOffset: CGFloat = -200

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                Text("welcome_title")
                    .font(.title)
                Image(uiImage: UIImage(named: "AppIcon") ?? .init())
                    .resizable()
                    .frame(width: 200, height: 200)
                    .offset(x: imageOffset, y: 0)
                    .animation(.easeInOut, value: imageOffset)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("welcome_context")
                    .padding(.vertical)
                    .font(.body)
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        helloSeen = true
                        navigateToHome.toggle()
                    } label: {
                        Text("welcome_go_button")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(tintColor)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    .shadow(radius: 3)
                    .opacity(buttonOpacity)
                    .fullScreenCover(isPresented: $navigateToHome, content: {
                        HomeManagerView()
                    })
                    Spacer()
                }
            }
            .padding()
        }
        .onAppear(perform: showGoButton)
    }

    private func showGoButton() {
        imageTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1, repeats: true, block: { timer in
                if imageOffset == 0 {
                    timer.invalidate()
                } else {
                    imageOffset += 10
                }
            })
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + 2.0) {
                buttonTimer = Timer
                    .scheduledTimer(
                        withTimeInterval: 0.1,
                        repeats: true) { timer in
                            if buttonOpacity == 1.0 {
                                timer.invalidate()
                            } else {
                                buttonOpacity += 0.1
                            }
                        }
            }
    }
}

#Preview {
    HelloView()
}
