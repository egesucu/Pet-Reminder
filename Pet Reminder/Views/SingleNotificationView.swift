//
//  SingleNotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import UserNotifications

struct SingleNotificationView: View {
    
    @EnvironmentObject var pet : PetModel
    var selectedTime : LocalizedStringKey
    @State private var time: Date = Date()
    @Environment(\.managedObjectContext) var moc
    
    
    var body: some View {
        
        VStack(alignment: .center) {
            Spacer()
            Text(selectedTime).font(.largeTitle)
            Spacer()
            DatePicker("Please enter a date", selection: $time, displayedComponents: .hourAndMinute).labelsHidden().environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr")).padding().clipped().shadow(color: Color(.label).opacity(0.6),radius: 4, x:0, y:2)
            Spacer()
            
            Button(action: {
                self.savePet()
            }) {
                Text("Submit").font(.largeTitle).foregroundColor(Color(.systemBackground)).padding().background(Color(.systemGreen)).cornerRadius(20)
            }
            
        }.padding()
        
        
    }
    
    private func savePet(){
        
        let addedPet = Pet(context: self.moc)
        addedPet.name = self.pet.name
        addedPet.id = UUID()
        addedPet.image = self.pet.imageData
        addedPet.birthday = self.pet.birthday
        
        
        if selectedTime == "Morning-Time" {
            addedPet.morningTime = self.time
        } else if selectedTime == "Evening-Time"{
            addedPet.eveningTime = self.time
        } else {
            print("Error on Getting time selection")
        }
        
        do {
            try self.moc.save()
            self.createNotification()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func createNotification(){
        
        if askNotificationRequest(){
            
            if selectedTime == "Morning-Time" {
                 NotificationManager.createNotification(from: time, identifier: "\(pet.name)-morning-notification", name: pet.name)
            } else if selectedTime == "Evening-Time"{
                NotificationManager.createNotification(from: time, identifier: "\(pet.name)-evening-notification", name: pet.name)
            } else {
                print("Error on Getting time selection")
            }
            
//            Create Birthday Notification
            NotificationManager.createNotification(from: self.pet.birthday, identifier: "\(pet.name)-birthday-notification", name: pet.name)

            
        }
        
        
    }
    
    
    private func askNotificationRequest()->Bool{
        
        var result = false
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                result = true
            } else if let error = error {
                print(error.localizedDescription)
                result =  false
            }
        }
        return result
    }
}

struct SingleNotificationView_Previews: PreviewProvider {
    
    static var previews: some View {
        SingleNotificationView(selectedTime: "").environment(\.locale, .init(identifier: "en"))

    }
}
