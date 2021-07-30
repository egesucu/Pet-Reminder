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
            
            ZStack{
                if feedType == 1 {
                    MorningView
                        .padding()
                    
                } else if feedType == 2 {
                    EveningView
                        .padding()
                    
                } else {
                    BothView
                        .padding()
                }
            }
            
            
            Spacer()
            Button {
                self.showHomeSheet.toggle()
                
                
                switch feedType{
                    case 0:
                        self.petManager.getSelection(selection: .both)
                        self.petManager.getDates(morning: morningFeed, evening: eveningFeed)
                    case 1:
                        self.petManager.getSelection(selection: .morning)
                        self.petManager.getDates(morning: morningFeed,evening: nil)
                    case 2:
                        self.petManager.getSelection(selection: .evening)
                        self.petManager.getDates(morning: nil, evening: eveningFeed)
                    default:
                        self.petManager.getSelection(selection: .both)
                        self.petManager.getDates(morning: morningFeed, evening: eveningFeed)
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
                MainView()
            }
            
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
            HStack {
                Image("morning")
                    .resizable()
                    .frame(maxWidth: 100, maxHeight: 80)
                    .cornerRadius(15)
                Spacer()
                DatePicker("Morning", selection: $morningFeed, displayedComponents: .hourAndMinute)
                
            }
            HStack{
                Image("evening")
                    .resizable()
                    .frame(maxWidth: 100, maxHeight: 80)
                    .cornerRadius(15)
                Spacer()
                DatePicker("Evening", selection: $eveningFeed, displayedComponents: .hourAndMinute)
            }
            
        }
    }
}

struct SetupNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNotificationView(petManager: PetManager())
    }
}
