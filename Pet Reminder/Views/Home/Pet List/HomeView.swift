//
//  HomeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import CoreData

struct HomeView: View {

    @AppStorage(Strings.tintColor) var tintColor = Color.green
    @Binding var tappedTwice: Bool
    @State private var addPet = false

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    private var pets: FetchedResults<Pet>

    var body: some View {
        NavigationStack {
            VStack {
                if pets.count > 0 {
                    ScrollViewReader(content: { proxy in
                        List {
                            ForEach(pets, id: \.name) { pet in
                                NavigationLink {
                                    PetDetailView(pet: pet)
                                } label: {
                                    PetCell(pet: pet)
                                }
                            }
                            .onDelete(perform: delete)
                            .onChange(of: tappedTwice) {
                                withAnimation {
                                    proxy.scrollTo(1)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    })
                } else {
                    Text("pet_no_pet")
                }
            }
            .toolbar(content: addButtonToolbar)
            .sheet(isPresented: $addPet, onDismiss: { }, content: {
                AddPetView()
            })
        }
        .navigationViewStyle(.stack)

    }

    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
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

    func delete(at offsets: IndexSet) {

        for index in offsets {
            let pet = pets[index]
            viewContext.delete(pet)
        }

    }
}

struct HomeViewPreview: PreviewProvider {

    static var previews: some View {
        HomeView(tappedTwice: .constant(false))
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
    }
}
