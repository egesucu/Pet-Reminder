//
//  PetListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct PetListView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    private var pets : FetchedResults<Pet>
    
    var body: some View {
        List{
            ForEach(pets){ pet in
                NavigationLink(
                    destination: PetChangeView(pet: pet),
                    label: {
                        PetCell(pet: pet).padding()
                    })
                
                    
            }.onDelete { indexSet in
                for index in indexSet{
                    viewContext.delete(pets[index])
                }
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        .navigationTitle(Text("Manage Pets"))
       
    }
}

struct PetListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PetListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
