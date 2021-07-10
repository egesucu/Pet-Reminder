//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    
    @StateObject var petManager : PetManager
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var showProgressStatus = false
    @State private var petSaved = false
    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    @State private var morningOn = false
    @State private var eveningOn = false
    
    var body: some View {
        VStack {
            
            HStack {
                ZStack(alignment: .center) {
                    Image("morning")
                        .resizable()
                        .scaledToFit()
                        .overlay(Color.black.opacity(0.4))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .frame(maxWidth: 300)
                        
                    .padding()
                    Text("Morning").font(.title).foregroundColor(.white)
                }
                DatePicker("Choose a time", selection: $eveningTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .accentColor(morningOn ? .black : .gray)
                    
                    .disabled(!morningOn)
                Toggle("Morning", isOn: $morningOn)
                    .font(.title.bold()).labelsHidden()
            }.padding()
            HStack {
                ZStack(alignment: .center) {
                    Image("evening")
                        .resizable()
                        .scaledToFit()
                        .overlay(Color.black.opacity(0.4))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .frame(maxWidth: 300)
                        
                    .padding()
                    Text("Evening").font(.title).foregroundColor(.white)
                }
                DatePicker("Choose a time", selection: $eveningTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .disabled(!eveningOn)
                Toggle("Evening", isOn: $eveningOn)
                    .font(.title.bold()).labelsHidden()
            }.padding()
            
        }
        .fullScreenCover(isPresented: $petSaved, content: {
            HomeView()
        })
        .navigationBarTitle("Notification")
    }
    
    func savePet(){
        
        petSaved = self.petManager.savePet(context: viewContext, morningTime: morningTime, eveningTime: eveningTime)
            

    }
    

}

struct MultipleNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationView(petManager: PetManager())
        }.navigationViewStyle(.stack)
    }
}
