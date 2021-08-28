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
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    private var pets : FetchedResults<Pet>
    
    @State private var addPet = false
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                if pets.count > 0 {
                    List{
                        ForEach(pets, id: \.name){ pet in
                            NavigationLink( destination: PetDetailView(pet: pet,context: viewContext)) {
                                PetCell(pet: pet).padding()
                            }
                        }
                        .onDelete(perform: delete)
                        .navigationTitle("Evcil Hayvanlar")
                    }
                    .listStyle(InsetGroupedListStyle())
                    .sheet(isPresented: $addPet, content: {
                        SetupNameView()
                    })
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.addPet.toggle()
                            }, label: {
                                Label("Add", systemImage: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                            })
                        }
                })
                } else {
                    Text("No Pets added yet, Let's add one.")
                }
            }
            .navigationTitle("Pets")
            Text("Select an animal to view.")
        }
        
    }
    
    
    
    func delete(at offsets: IndexSet){
        
        for index in offsets{
            let pet = pets[index]
            viewContext.delete(pet)
        }
        
        PersistenceController.shared.save()
        
    }
    
    
    
    
    
}

struct PetCell: View {
    var pet: Pet
    
    var body: some View{
        HStack{
            Image(uiImage: UIImage(data: pet.image ?? Data()) ?? UIImage(named: "default-animal")!)
                .resizable()
                .frame(width: 80, height:80)
                .clipShape(Circle())
                .padding([.trailing])
            Text(pet.name ?? "Error")
                .foregroundColor(Color(.label))
                .font(.title)
        }
    }
    
}
