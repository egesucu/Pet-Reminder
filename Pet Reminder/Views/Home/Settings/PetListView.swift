//
//  PetListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct PetListView: View {

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
        private var pets: FetchedResults<Pet>

    var body: some View {
        List {
            ForEach(pets, id: \.name) { pet in
                NavigationLink(
                    destination: PetChangeView(pet: pet),
                    label: {
                        PetCell(pet: pet)
                            .padding()
                    })
            }.onDelete { indexSet in
                deletePet(at: indexSet)
            }
        }
        .navigationTitle(Text("manage_pet_title"))
    }

    func deletePet(at indexSet: IndexSet) {
        for index in indexSet {
            let pet = pets[index]
            viewContext.delete(pet)
        }
    }
}

#Preview {
    PetListView()
}
