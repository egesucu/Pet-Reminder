//
//  PetListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct PetListView: View {

    @Environment(\.modelContext)
    private var viewContext
    @Environment(\.undoManager) var undoManager

    @Query var pets: [Pet]
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
            do {
                try viewContext.save()
                showUndoButton.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    showUndoButton.toggle()
                }
            } catch let error {
                print(error.localizedDescription)
            }

        }
    }
}

#Preview {
    PetListView()
}
