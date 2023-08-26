//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen
    @AppStorage("seenHello") var helloSeen = false
    @State private var navigateToHome = false
    @State private var shouldAnimate = false

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                Text("welcome_title")
                    .font(.title)
                Image(uiImage: UIImage(named: "AppIcon") ?? .init())
                    .resizable()
                    .frame(width: 200, height: 200)
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
                    .fullScreenCover(isPresented: $navigateToHome, content: {
                        HomeManagerView()
                    })
                    Spacer()
                }
            }
            .padding()
            .opacity(shouldAnimate ? 1.0 : 0.0)
        }
        .onAppear(perform: animateView)
    }

    private func animateView() {
        withAnimation(.spring().speed(0.2)) {
            shouldAnimate.toggle()
        }
    }

}

#Preview {
    HelloView()
}
