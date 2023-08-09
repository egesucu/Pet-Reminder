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

    var reference: PetListViewReference = .petList
    
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.undoManager) var undoManager
    @State private var addPet = false
    @AppStorage(Strings.tintColor) var tintColor = Color.green

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    var pets: FetchedResults<Pet>
    @State private var showUndoButton = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    if pets.count > 0 {
                        List {
                            ForEach(pets, id: \.name) { pet in
                                NavigationLink {
                                    switch reference {
                                    case .petList:
                                        PetDetailView(pet: pet)
                                    case .settings:
                                        PetChangeView(pet: pet)
                                    }
                                } label: {
                                    PetCell(pet: pet)
                                        .padding()
                                        .transition(.slide)
                                }
                            }.onDelete { indexSet in
                                withAnimation {
                                    deletePet(at: indexSet)
                                }
                                
                            }

                        }
                    } else {
                        switch reference {
                        case .petList:
                            EmptyPageView(onAddPet: {
                                addPet.toggle()
                            }, emptyPageReference: .petList)
                        case .settings:
                            EmptyPageView(emptyPageReference: .settings)
                        }
                    }
                }
                if showUndoButton {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGroupedBackground))
                            .padding(.horizontal, 10)
                        Button("Undo Last Change") {
                            withAnimation {
                                undoManager?.undo()
                                showUndoButton.toggle()
                            }
                        }
                    }
                    .frame(height: 40)
                }
            }
            .toolbar(content: addButtonToolbar)
            .onAppear(perform: {
                viewContext.undoManager = undoManager
            })
            .navigationTitle(petListTitle)
            .sheet(isPresented: $addPet, onDismiss: { }, content: {
                AddPetView()
            })
        }
    }
    
    private var petListTitle: Text {
        Text(reference == .settings ? "manage_pet_title" : "pet_name_title")
    }
    
    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if reference == .petList && pets.count > 0 {
                Button(action: {
                    self.addPet.toggle()
                }, label: {
                    Image(systemName: SFSymbols.add)
                        .accessibilityLabel(Text("add_animal_accessible_label"))
                        .foregroundColor(tintColor)
                        .font(.title)
                })
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
    NavigationStack {
        PetListView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
        )
    }
}

enum PetListViewReference {
    case petList, settings
}
