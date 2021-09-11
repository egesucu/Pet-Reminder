//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct PetChangeView: View {
    
    var pet: Pet
    let persistence = PersistenceController.shared
    let notificationManager = NotificationManager.shared
    
    @State private var nameText = ""
    @State private var petImage : UIImage? = nil
    @State private var birthday = Date()
    @State private var selection = 0
    @State private var morningDate = Date()
    @State private var eveningDate = Date()
    
    var body: some View {
        
        VStack {
            Image("default-animal")
                .resizable()
                .frame(width: 200, height: 200, alignment: .center)
            Form{
                Section{
                    TextField("Tap to Change", text: $nameText)
                        .onChange(of: nameText, perform: { _ in
                            self.changeName()
                        })
                    DatePicker("Date", selection: $birthday, displayedComponents: .date)
                        .onChange(of: birthday) { _ in
                            self.changeBirthday()
                        }
                }
                Section{
                    Picker("Notification Settings", selection: $selection) {
                        Text("Both").tag(0)
                        Text("Morning").tag(1)
                        Text("Evening").tag(2)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selection == 0{
                        DatePicker("Morning", selection: $morningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: morningDate) { _ in
                                self.changeNotification(for: .morning)
                            }
                        DatePicker("Evening", selection: $eveningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningDate) { _ in
                                self.changeNotification(for: .evening)
                            }
                    } else if selection == 1 {
                        DatePicker("Morning", selection: $morningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: morningDate) { _ in
                                self.changeNotification(for: .morning)
                            }
                    } else if selection == 2{
                        DatePicker("Evening", selection: $eveningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningDate) { _ in
                                self.changeNotification(for: .evening)
                            }
                    }
                }
                
            }
            .navigationTitle(pet.name ?? "Pet")
        }
        .onAppear{
            getPetData()
        }
        
    }
    
    func getPetData(){
        self.birthday = pet.birthday ?? Date()
        self.nameText = pet.name!
        self.petImage = UIImage(data: pet.image ?? Data()) ?? nil
        let selection = pet.selection
        switch selection {
        case .both:
            self.selection = 0
        case .morning:
            self.selection = 1
        case .evening:
            self.selection = 2
        }
        if let morning = pet.morningTime{
            self.morningDate = morning
        }
        if let evening = pet.eveningTime{
            self.eveningDate = evening
        }
    }
    
    func changeName(){
        pet.name = nameText
        persistence.save()
    }
    
    func changeBirthday(){
        pet.birthday = birthday
        persistence.save()
    }
    
    func changeNotification(for selection: Selection){
        switch selection {
        case .both:
            notificationManager.removeNotification(of: pet, with: .morning)
            notificationManager.removeNotification(of: pet, with: .evening)
            notificationManager.createNotification(of: pet, with: .morning, date: morningDate)
            notificationManager.createNotification(of: pet, with: .evening, date: eveningDate)
        case .morning:
            notificationManager.removeNotification(of: pet, with: .morning)
            notificationManager.createNotification(of: pet, with: .morning, date: morningDate)
        case .evening:
            notificationManager.removeNotification(of: pet, with: .evening)
            notificationManager.createNotification(of: pet, with: .evening, date: eveningDate)
        }
        let (morningTime, eveningTime) = (pet.morningTime,pet.eveningTime)
        
        if morningTime != nil {
            pet.morningTime = morningDate
        }
        if eveningTime != nil {
            pet.eveningTime = eveningDate
        }
        persistence.save()
    }
}

struct PetChangeView_Previews: PreviewProvider {
    static var previews: some View {
        let pet = Pet(context: PersistenceController.preview.container.viewContext)
        NavigationView {
            PetChangeView(pet: pet)
        }
    }
}
