//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct NotificationView: View {
    
    @StateObject var demoPet : DemoPet
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var showProgressStatus = false
    @State private var petSaved = false
    @State private var finishProgress = false
    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    
    var body: some View {
        VStack {
            
            switch (demoPet.type){
            
            case .morning:
                MorningNotificationView(morningTime: $morningTime)
            case .evening:
                EveningNotificationView(eveningTime: $eveningTime)
            case .both:
                BothNotificationView(morningTime: $morningTime, eveningTime: $eveningTime)
            }
            Button(action: savePet, label: {
                Text("Setup")
            })
            .font(.title)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .fullScreenCover(isPresented: $petSaved, content: {
                RootView().environment(\.managedObjectContext, viewContext)
                
            })
            
        }.padding()
    }
    
    func savePet(){
        
        let newPet = Pet(context: viewContext)
        
        debugPrint("I'm at saving pet")
        
        newPet.id = UUID()
        newPet.name = demoPet.name
        newPet.birthday = demoPet.birthday
        
        if let data = demoPet.petImage.pngData() {
            newPet.image = data
        } else {
            debugPrint("I couldn't convert image to png data")
        }
        
        switch demoPet.type {
        case .morning:
            newPet.morningTime = morningTime
            newPet.eveningTime = nil
        case .evening:
            newPet.morningTime = nil
            newPet.eveningTime = eveningTime
        case .both:
            newPet.morningTime = morningTime
            newPet.eveningTime = eveningTime
        }
        
        newPet.eveningFed = false
        newPet.morningFed = false
        
        
        debugPrint(newPet)
        
        do {
            try viewContext.save()
            
            debugPrint("Animal saved")
            
            petSaved = true
            
            let petAvailable = UserDefaults.standard.bool(forKey: "petAvailable")
            
            if !petAvailable {
                UserDefaults.standard.setValue(petSaved, forKey: "petAvailable")
            }
            
        } catch {
            print(error.localizedDescription)
            debugPrint("An error occured with")
        }
        
    }
    

}

struct MultipleNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(demoPet: DemoPet())
    }
}
