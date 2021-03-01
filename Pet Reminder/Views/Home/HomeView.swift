//
//  HomeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import CoreData
import EventKit

struct HomeView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var pets : FetchedResults<Pet>
    
    @State private var selectedPet : Pet?
    @State private var allPetsRemoved = false
    
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                
                if let selectedPet = selectedPet {
                    TopView(name: selectedPet.name ?? "")
                } else if let firstPet = pets.first{
                    TopView(name: firstPet.name!)
                }
                
                ScrollView(.horizontal){
                    HStack {
                        ForEach(pets){ pet in
                            CircularAnimalView(pet: pet)
                                .onTapGesture {
                                    selectPet(pet)
                                }
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(action: {
                                        withAnimation{
                                            self.removePet(pet: pet)
                                            selectedPet = pets.first!
                                        }
                                    }, label: {
                                        Text("Remove Pet")
                                        Image(systemName: "trash")
                                    })
                                    Button(action: {}, label: {
                                        Text("Cancel")
                                        Image(systemName: "xmark")
                                    })
                                }))
                                .sheet(isPresented: $allPetsRemoved, content: {
                                    HelloView()
                                })
                        }
                        .padding()
                    }
                }
                
                PetDetailView(pet: selectedPet ?? pets.first!)
                
                Text("Daily Routine")
                    .font(.largeTitle)
                    .padding()
                if let firstPet = pets.first {
                    DailyRoutineView(selectedPet: selectedPet ?? firstPet)
                }
                
                
                Spacer()
                
            }
        }
        
    }
    
    func selectPet(_ pet: Pet){
        selectedPet = pet
        
    }
    
    func removePet(pet: Pet){
        viewContext.delete(pet)
        try? viewContext.save()
        
        if let firstPet = pets.first{
            selectedPet = firstPet
        } else if pets.isEmpty {
            UserDefaults.standard.removeObject(forKey: "petSaved")
            allPetsRemoved = true
            
        }
        
    }
    
}

struct TopView : View {
    var name : String
    var body: some View{
        Text("Hello \(name)")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding([.top,.bottom],30)
            .padding(.leading)
        Text("Your Pets")
            .font(.largeTitle)
            .padding()
    }
}

struct CircularAnimalView : View {
    
    var pet : Pet
    var body: some View {
        
        VStack{
            if let imageData = pet.image,
               let uiImage = UIImage(data: imageData){
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
            } else {
                Image("default-animal")
            }
            Text(pet.name ?? "Error Name")
        }
        
    }
    
}


struct PetDetailView: View {
    
    var pet : Pet
    var body: some View{
        
        HStack{
            Spacer()
            if let data = pet.image,
               let image = UIImage(data: data){
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 30, maxWidth: 100, minHeight: 30, maxHeight: 100)
                    .padding()
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
                
            }
            Spacer()
        }
    }
}

struct DailyRoutineView : View {
    
    var selectedPet : Pet
    @Environment(\.managedObjectContext)
    private var viewContext
    @State private var morningSelected = false
    @State private var eveningSelected = false
    
    var body: some View{
        
        HStack(alignment: .center, spacing: 20, content: {
            Spacer()
            if selectedPet.morningTime != nil{
                ZStack {
                    Rectangle()
                        .fill(Color(.systemYellow))
                        .frame(width: 100, height: 92, alignment: .center)
                        .cornerRadius(15)
                        .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                    VStack{
                        Text("Morning")
                        Toggle(isOn: Binding<Bool>(
                            get: {
                                selectedPet.morningFed
                            } ,
                            set: {
                                selectedPet.morningFed = $0
                                try? viewContext.save()
                            }
                        ), label: {
                            Text("")
                        }).labelsHidden()
                        
                    }
                    
                    .padding(20)
                }
            }
            Spacer()
            if selectedPet.eveningTime != nil {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemBlue))
                        .frame(width: 100, height: 92, alignment: .center)
                        .cornerRadius(15)
                        .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                    VStack{
                        Text("Evening")
                        Toggle(isOn: Binding<Bool>(
                            get: {
                                selectedPet.eveningFed
                            } ,
                            set: {
                                selectedPet.eveningFed = $0
                                try? viewContext.save()
                            }
                            
                            
                        ), label: {
                            Text("")
                        }).labelsHidden()
                        .background(Color.blue)
                    }
                    
                    .padding(20)
                }
            }
            Spacer()
        })
        
    }
    
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
