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
                            NavigationLink {
                                PetDetailView(pet: pet, context: viewContext)
                            } label: {
                                PetCell(pet: pet)
                            }
                        }
                        .onDelete(perform: delete)
                        .navigationTitle("pet_name_title")
                    }
                    .listStyle(.insetGrouped)
                    .sheet(isPresented: $addPet, onDismiss: {
                        viewContext.refreshAllObjects()
                    }, content: {
                        SetupNameView()
                    })
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.addPet.toggle()
                            }, label: {
                                Label("add_animal_accessible_label", systemImage: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title)
                            })
                        }
                })
                } else {
                    Text("pet_no_pet")
                }
            }
            .navigationTitle("pet_name_title")
            Text("pet_select")
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

struct HomeViewPreview: PreviewProvider{
    
    static var previews: some View{
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
