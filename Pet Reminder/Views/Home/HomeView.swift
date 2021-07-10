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
                    LazyHStack {
                        ForEach(pets){ pet in
                            CircularAnimalView(pet: pet)
                                .onTapGesture {
                                    selectPet(pet)
                                }
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(action: {
                                        withAnimation{
                                            self.removePet(pet: pet)
                                            selectedPet = pets.first ?? nil
                                        }
                                    }, label: {
                                        Text("Remove Pet").foregroundColor(Color.red)
                                        Image(systemName: "trash").foregroundColor(Color.red)
                                    })
                                    Button(action: {}, label: {
                                        Text("Cancel")
                                        Image(systemName: "xmark")
                                    })
                                })).id(UUID())
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
    
    @State private var showAddAnimal = false

    var name : String
    var body: some View{
        VStack {
            HStack {
                Text("Hello \(name)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding([.top,.bottom],30)
                    .padding(.leading)
                Spacer()
                Button(action: {
                    self.showAddAnimal.toggle()
                }, label: {
                    Image(systemName: "plus.circle.fill").accessibilityLabel("Add Animal")
                        .font(.largeTitle)
                    
                })
                .padding()
                .fullScreenCover(isPresented: $showAddAnimal, content: {
                   SetupNameView()
                })
            }
            Text("Your Pets")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.leading)
        }
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
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
            } else {
                Image("default-animal")
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
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
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 30, maxWidth: 100, minHeight: 30, maxHeight: 100)
                    .padding()
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
                
            } else {
                Image("default-animal")
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 30, maxWidth: 100, minHeight: 30, maxHeight: 100)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
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
            
            selectedPet.eveningTime != nil ? AnyView(Spacer()) : AnyView(EmptyView())
            
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
