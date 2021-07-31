//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by egesucu on 31.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct PetDetailView: View {
    
    var pet : Pet
    @State private var morningOn = false
    @State private var eveningOn = false
    
    let feedback = UINotificationFeedbackGenerator()

    var body: some View {
        VStack{
            
            if let imageData = pet.image{
                ZStack {
                    Rectangle().fill(Color(.systemGreen)).cornerRadius(25).shadow(radius: 10)
                        .frame(width: 250, height: 250, alignment: .center)
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200, alignment: .center)
                        .clipShape(Circle())
                }
                    
            } else {
                ZStack {
                    Rectangle().fill(Color(.systemGreen)).cornerRadius(25).shadow(radius: 10)
                        .frame(width: 250, height: 250, alignment: .center)
                    Image("default-animal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200, alignment: .center)
                        .clipShape(Circle())
                }
            }
            Spacer()
            
            HStack(spacing: 30){
                
                if pet.morningTime != nil{
                    VStack {
                        Label {
                            Text("Morning")
                                .foregroundColor(.black)
                                .font(.title.bold())
                        } icon: {
                            Image(systemName: morningOn ? "sun.max.fill" : "sun.max")
                                .foregroundColor(.yellow)
                                .font(.largeTitle.bold())
                        }.font(.title.bold())

                        MorningView(morningOn: $morningOn,pet: pet, feedback: feedback, perform: save)
                            .onTapGesture {
                                feedback.notificationOccurred(.success)
                                morningOn.toggle()
                                pet.morningFed = morningOn
                                save()
                        }
                            .cornerRadius(20)
                            .frame(width:150,height:150)
                    }
                }
                
                if pet.eveningTime != nil{
                    VStack {
                        Label {
                            Text("Evening")
                                .foregroundColor(.black)
                                .font(.title.bold())
                        } icon: {
                            Image(systemName: eveningOn ? "moon.fill" : "moon")
                                .foregroundColor(.blue)
                                .font(.largeTitle.bold())
                        }
                        EveningView(eveningOn: $eveningOn, pet: pet,feedback: feedback,perform: save)
                            .cornerRadius(20)
                            .frame(width:150,height:150)
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Hello \(pet.name ?? "Error")")
    }
    
    func save(){
        PersistenceController.shared.save()
    }
}

struct MorningView : View {
    @Binding var morningOn : Bool
    var pet: Pet
    var feedback: UINotificationFeedbackGenerator
    var perform: () -> ()
    
    var body: some View{
                Image(systemName: morningOn ? "square.fill" : "square")
                    .font(.system(size: 50))
                    .animation(.easeInOut, value: morningOn)
                    .onTapGesture {
                        feedback.notificationOccurred(.success)
                        morningOn.toggle()
                        pet.eveningFed = morningOn
                        perform()
                }
    }
}


struct EveningView : View {
    @Binding var eveningOn : Bool
    var pet: Pet
    var feedback: UINotificationFeedbackGenerator
    var perform: () -> ()
    
    var body: some View{
        withAnimation {
            Image(systemName: eveningOn ? "square.fill" : "square")
                .font(.system(size: 50))
                .animation(.easeInOut, value: eveningOn)
        }
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
            PetDetailView(pet: demo)
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
