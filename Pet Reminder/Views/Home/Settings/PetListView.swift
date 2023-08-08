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
    @Environment(\.undoManager) var undoManager

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    var pets: FetchedResults<Pet>
    @State private var showUndoButton = false

    var body: some View {
        ZStack {
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
            .onAppear(perform: {
                viewContext.undoManager = undoManager
            })
            .navigationTitle(Text("manage_pet_title"))
        }
        if showUndoButton {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGroupedBackground))
                .padding(.horizontal, 10)
            Button("Undo Last Change") {
                undoManager?.undo()
            }
        }
    }

    func deletePet(at indexSet: IndexSet) {
        for index in indexSet {
            let pet = pets[index]
            viewContext.delete(pet)
            PersistenceController.shared.save()
            showUndoButton.toggle()
        }
    }
}

#Preview {
    PetListView()
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}
