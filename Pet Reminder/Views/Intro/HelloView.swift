//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct HelloView: View {
    @StateObject var storeManager: StoreManager
    @Query var pets: [Pet]

//    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    let manager = DataManager.shared

    @State private var showSetup = false
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var petsAvailable = false
    @State private var navigateToHome = false

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image(.petReminder)
                    .resizable()
                    .scaledToFit()
                    .padding([.top, .bottom])
                Text("welcome_title")
                    .padding([.top, .bottom])
                    .font(.title)
                Spacer()
                Text("welcome_context")
                    .padding([.top, .bottom])
                    .font(.body)
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        self.showSetup.toggle()
                    } label: {
                        Text("welcome_add_pet")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.tintColor)
                    .cornerRadius(5)
                    .shadow(radius: 3)
                    .sheet(isPresented: $showSetup, onDismiss: {
                        navigateToHome.toggle()
                    }, content: {
                        AddPetView()
                    })
                    .fullScreenCover(isPresented: $navigateToHome, content: {
                        HomeManagerView(storeManager: storeManager)
                    })

                    Spacer()

                }

            }
            .padding()
        }
    }
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        let storeManager = StoreManager()
        return Group {
            HelloView(storeManager: storeManager)
        }

    }
}
