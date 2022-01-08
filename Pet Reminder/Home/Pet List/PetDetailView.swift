//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by egesucu on 31.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct PetDetailView: View {
    
    var pet : Pet
    @State private var morningOn = false
    @State private var eveningOn = false
    
    let feedback = UINotificationFeedbackGenerator()
    var context: NSManagedObjectContext
    
    var body: some View {
        VStack{
            ESImageView(data: pet.image)
            Spacer()
            HStack(spacing: 30){
                if pet.morningTime != nil{
                    MorningCheckboxView(morningOn: $morningOn)
                        .onChange(of: morningOn, perform: { value in
                            feedback.notificationOccurred(.success)
                            pet.morningFed = value
                            self.save()
                        })
                        .onTapGesture {
                            morningOn.toggle()
                        }
                }
                if pet.eveningTime != nil{
                    EveningCheckboxView(eveningOn: $eveningOn)
                        .onChange(of: eveningOn, perform: { value in
                            feedback.notificationOccurred(.success)
                            pet.eveningFed = value
                            self.save()
                        })
                        .onTapGesture {
                            eveningOn.toggle()
                        }
                }
            }
            Spacer()
        }
        .onAppear{
            morningOn = pet.morningFed
            eveningOn = pet.eveningFed
            
        }
        .navigationTitle(Text("pet_name_title_\(pet.name ?? "")"))
    }
    
    func save(){
        PersistenceController.shared.save()
    }
}

struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let persistence = PersistenceController.preview
        
        let demo = Pet(context: persistence.container.viewContext)
        demo.name = "Viski"
        demo.morningFed = false
        demo.morningTime = Date()
        demo.eveningFed = true
        demo.eveningTime = Date()
        
        return NavigationView {
            PetDetailView(pet: demo, context: persistence.container.viewContext)
        }
    }
}
