//
//  SetupNotificationView.swift
//  SetupNotificationView
//
//  Created by egesucu on 30.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct SetupNotificationView: View {
    
    @State private var feedType = 0
    @State private var morningFeed = Date()
    @State private var eveningFeed = Date()
    @State private var showHomeSheet = false
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var petManager : PetManager
    
    var body: some View {
        
        VStack{
            
            Text("Choose a Feed Time")
                .font(.title).bold()
                .padding([.top,.bottom])
            
            Picker(selection: $feedType, label: Text("Choose a type")) {
                Text("Both").tag(0)
                Text("Morning").tag(1)
                Text("Evening").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Spacer()
            NotificationType()
                .padding()
            Spacer()
            AddPetButton()
        }
        
        
    }
    
    @ViewBuilder func NotificationType() -> some View {
        switch feedType {
        case 1:
            MorningView
        case 2:
            EveningView
        default:
            BothView
        }
    }
    
    var MorningView: some View {
        HStack {
            Image("morning")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("Morning", selection: $morningFeed, displayedComponents: .hourAndMinute)
            
        }
        
    }
    
    func AddPetButton() -> some View {
        Button {
            self.showHomeSheet.toggle()
            
            switch feedType{
            case 1:
                self.petManager.selection = .morning
                self.petManager.morningTime = morningFeed
            case 2:
                self.petManager.selection = .evening
                self.petManager.eveningTime = eveningFeed
            default:
                self.petManager.selection = .both
                self.petManager.morningTime = morningFeed
                self.petManager.eveningTime = eveningFeed
            }
            self.petManager.savePet()
        } label: {
            Text("Add Animal")
                .font(.title)
                .foregroundColor(.green)
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
        .fullScreenCover(isPresented: $showHomeSheet) {
            MainView(storeManager: StoreManager())
        }
    }
    
    var EveningView: some View{
        HStack{
            Image("evening")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("Evening", selection: $eveningFeed, displayedComponents: .hourAndMinute)
        }
    }
    
    var BothView: some View {
        VStack {
            MorningView
            EveningView
        }
    }
}

struct SetupNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNotificationView(petManager: PetManager())
    }
}
