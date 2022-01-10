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
            
            Text("feed_time_title")
                .font(.title).bold()
                .padding([.top,.bottom])
            
            Picker(selection: $feedType, label: Text("feed_time_title")) {
                Text("feed_selection_both").tag(0)
                Text("feed_selection_morning").tag(1)
                Text("feed_selection_evening").tag(2)
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
            DatePicker("feed_selection_morning", selection: $morningFeed, displayedComponents: .hourAndMinute)
            
        }
        
    }
    
    func AddPetButton() -> some View {
        Button {
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
            UserDefaults.standard.set(true, forKey: "petSaved")
            let rootViewController = UIApplication.shared.connectedScenes
                    .filter {$0.activationState == .foregroundActive }
                    .map {$0 as? UIWindowScene }
                    .compactMap { $0 }
                    .first?.windows
                    .filter({ $0.isKeyWindow }).first?.rootViewController
                
                rootViewController?.dismiss(animated: true) {
                }

        } label: {
            Text("add_animal_button")
                .font(.title)
                .foregroundColor(.green)
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
    }
    
    var EveningView: some View{
        HStack{
            Image("evening")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_evening", selection: $eveningFeed, displayedComponents: .hourAndMinute)
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
