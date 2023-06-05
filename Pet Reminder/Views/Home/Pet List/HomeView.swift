//
//  HomeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2020.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData
import EventKit

struct HomeView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    private var pets : FetchedResults<Pet>
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    
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
                        .navigationTitle(Strings.petNameTitle)
                    }
                    .listStyle(.insetGrouped)
                    .sheet(isPresented: $addPet, onDismiss: {
                        DispatchQueue.main.async {
                            viewContext.refreshAllObjects()
                        }
                    }, content: {
                        AddPetView()
                    })
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.addPet.toggle()
                            }, label: {
                                Label(Strings.addAnimalAccessibleLabel, systemImage: SFSymbols.add)
                                    .foregroundColor(tintColor)
                                    .font(.title)
                            })
                        }
                })
                } else {
                    Text(Strings.petNoPet)
                }
            }
            .navigationTitle(Strings.petNameTitle)
            Text(Strings.petSelect)
        }.navigationViewStyle(.stack)
        
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