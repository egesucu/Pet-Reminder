//
//  PetChangeListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import CoreData
import OSLog

struct PetChangeListView: View {

    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.undoManager) var undoManager
    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    var pets: FetchedResults<Pet>
    @State private var showUndoButton = false
    @State private var buttonTimer: Timer?
    @State private var time = 0
    @State private var isEditing = false
    @State private var selectedPet: Pet?
    @State private var showSelectedPet = false

    var body: some View {
        petList
            .navigationTitle(Text("Choose Friend"))
    }

    private var petList: some View {
        LazyVGrid(columns: [.init(), .init()]) {
            ForEach(pets, id: \.name) { pet in
                VStack {
                    if isEditing {
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                ESImageView(data: pet.image)
                                    .clipShape(Circle())
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 40)
                                            .stroke(
                                                selectedPet == pet ? Color.yellow : Color.clear,
                                                lineWidth: 5
                                            )
                                    )
                                    .wiggling()
                                Text(pet.wrappedName)
                            }
                            Button {
                                withAnimation {
                                    deletePet(pet: pet)
                                    isEditing = false
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.red)
                                    .offset(x: 15, y: 0)
                            }

                        }
                    } else {
                        ESImageView(data: pet.image)
                            .clipShape(Circle())
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(
                                        selectedPet == pet ? Color.yellow : Color.clear,
                                        lineWidth: 5
                                    )
                            )

                        Text(pet.wrappedName)
                    }

                }
                .onTapGesture {
                    selectedPet = pet
                    showSelectedPet.toggle()
                    Logger
                        .viewCycle
                        .info("PR: Pet Selected: \(selectedPet?.name ?? "")")
                }
                .sheet(isPresented: $showSelectedPet, onDismiss: {
                    selectedPet = nil
                }, content: {
                    PetChangeView(pet: $selectedPet)
                        .presentationCornerRadius(25)
                        .presentationDragIndicator(.hidden)
                        .interactiveDismissDisabled()
                })
                .onLongPressGesture {
                    isEditing = true
                }
                .padding([.top, .leading])
            }
        }
    }

    func deletePet(pet: Pet) {
        if pet == selectedPet {
            selectedPet = nil
        }
        viewContext.delete(pet)
        PersistenceController.shared.save()
        showUndoButton.toggle()
        buttonTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if time == 10 {
                withAnimation {
                    showUndoButton = false
                    timer.invalidate()
                }
            } else {
                time += 1
            }
        })
    }
}

#Preview {
    NavigationStack {
        let preview = PersistenceController.preview.container.viewContext
        PetChangeListView()
            .environment(\.managedObjectContext, preview)
    }

}
