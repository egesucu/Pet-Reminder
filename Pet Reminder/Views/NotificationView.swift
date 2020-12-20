//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

enum NotificationType{
    case morning, evening, both
}

struct NotificationView: View {
    
    var type : NotificationType
    var name : String
    var birthday : Date
    var petImage : UIImage
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    @State private var morningDate : Date = Date()
    @State private var eveningDate : Date = Date()
    @State private var showProgressStatus = false
    @State private var petSaved = false
    @State private var finishProgress = false
    
    
    
    var body: some View {
        VStack {
            
            switch (type){
            
            case .morning:
                Text("Let's choose a morning notification")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom],10)
                
                DatePicker("Choose a time", selection: $morningDate, displayedComponents: .hourAndMinute)
                    .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                Spacer()
            case .evening:
                Text("Let's choose an evening notification")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom],10)
                
                DatePicker("Choose a time", selection: $morningDate, displayedComponents: .hourAndMinute)
                    .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                    .padding([.top,.bottom],10)
                Spacer()
            case .both:
                Text("First, choose a morning notification")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom],10)
                
                DatePicker("Choose a time", selection: $morningDate, displayedComponents: .hourAndMinute)
                    .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                Spacer()
                Text("Now, let's choose an evening notification")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom],10)
                
                DatePicker("Choose a time", selection: $morningDate, displayedComponents: .hourAndMinute)
                    .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                    .padding([.top,.bottom],10)
                Spacer()
            }
            
            Button("Setup"){
                savePet()
            }
            .font(.title)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .fullScreenCover(isPresented: $petSaved, content: {
                HomeView()
            })
            
        }.padding()
    }
    
    
    func savePet(){
        
        let newPet = Pet(context: viewContext)
        
        newPet.id = UUID()
        newPet.name = name
        newPet.birthday = birthday
        
        if let data = petImage.pngData() {
            newPet.image = data
        }
        
        switch type {
        case .morning:
            newPet.morningTime = morningDate
            newPet.eveningTime = nil
        case .evening:
            newPet.morningTime = nil
            newPet.eveningTime = eveningDate
        case .both:
            newPet.morningTime = morningDate
            newPet.eveningTime = eveningDate
        }
        
        newPet.eveningFed = false
        newPet.morningFed = false
        
        do {
            try viewContext.save()
            
            petSaved = true
            
            UserDefaults.standard.setValue(petSaved, forKey: "petSaved")
            
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    

}

struct MultipleNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(type: .both, name: "Viski", birthday: Date(), petImage: UIImage(named: "default-animal")!)
    }
}
