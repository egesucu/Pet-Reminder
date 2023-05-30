//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    @StateObject var storeManager : StoreManager
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var pets : FetchedResults<Pet>
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    
    let manager = DataManager.shared
    
    @State private var showSetup = false
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var petsAvailable = false
    @State private var navigateToHome = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Assets.petReminder.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .padding([.top,.bottom])
                Text(Strings.welcomeTitle)
                    .padding([.top,.bottom])
                    .font(.title)
                Spacer()
                Text(Strings.welcomeContext)
                    .padding([.top,.bottom])
                    .font(.body)
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        self.showSetup.toggle()
                    } label: {
                        Text(Strings.welcomeAddPet)
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(tintColor)
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
                
            }.padding()
        }
        .onAppear {
            context.refreshAllObjects()
        }
    }
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        let storeManager = StoreManager()
        return Group{
            HelloView(storeManager: storeManager)
        }
        
    }
}


