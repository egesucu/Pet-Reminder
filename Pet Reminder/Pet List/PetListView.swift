//
//  PetListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData
import OSLog

struct PetListView: View {
        
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.undoManager) var undoManager
    @State private var addPet = false
    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    var pets: FetchedResults<Pet>
    @State private var showUndoButton = false
    @State private var selectedPet: Pet?
    @State private var isEditing = false
    @State private var notificationManager = NotificationManager()
    
    @State private var buttonTimer: Timer?
    @State private var time = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if pets.count > 0 {
                        if selectedPet != nil {
                            petList
                        } else {
                            EmptyPageView(onAddPet: {
                                addPet.toggle()
                            }, emptyPageReference: .petList)
                        }
                        PetDetailView(pet: $selectedPet)
                    } else {
                        EmptyPageView(onAddPet: {
                            addPet.toggle()
                        }, emptyPageReference: .petList)
                    }
                }
            }
            .toolbar(content: addButtonToolbar)
            
            .onAppear {
                selectedPet = pets.first
                viewContext.undoManager = undoManager
            }
            .navigationTitle(petListTitle)
            .fullScreenCover(isPresented: $addPet, onDismiss: {
                viewContext.refreshAllObjects()
                selectedPet = pets.first
                Logger
                    .viewCycle
                    .debug("Pet Amount: \(pets.count)")
            }, content: {
                NewAddPetView()
            })
        }
    }
    
    private var petList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
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
                                                    defineColor(pet: pet),
                                                    lineWidth: 5
                                                )
                                        )
                                        .wiggling()
                                    Text(pet.wrappedName)
                                }
                                Button {
                                    deletePet(pet: pet)
                                    isEditing = false
                                } label: {
                                    Image(systemName: "circle.badge.xmark.fill")
                                        .foregroundStyle(Color.red)
                                        .font(.title)
                                }
                                
                            }
                        } else {
                            ESImageView(data: pet.image)
                                .clipShape(Circle())
                                .frame(width: 80, height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(
                                            defineColor(pet: pet),
                                            lineWidth: 5
                                        )
                                )
                            
                            Text(pet.wrappedName)
                        }
                        
                    }
                    .onTapGesture {
                        selectedPet = pet
                        Logger
                            .viewCycle
                            .info("PR: Pet Selected: \(selectedPet?.name ?? "")")
                    }
                    .onLongPressGesture {
                        isEditing = true
                    }
                    .padding([.top, .leading])
                    
                }
            }
            
        }
    }
    
    private func defineColor(pet: Pet) -> Color {
        selectedPet?.name == pet.wrappedName ? Color.yellow : Color.clear
    }
    
    private var petListTitle: Text {
        Text("pet_name_title")
    }
    
    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if isEditing {
                Button {
                    isEditing = false
                } label: {
                    Text("Done")
                }
            }
            if showUndoButton {
                Button {
                    undoManager?.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .foregroundColor(tintColor)
                        .font(.title)
                }
                
            }
            if pets.count > 0 {
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
    
    func deletePet(pet: Pet) {
        let tempPetName = pet.wrappedName
        viewContext.delete(pet)
        PersistenceController.shared.save()
        showUndoButton.toggle()
        buttonTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if time == 10 {
                withAnimation {
                    self.notificationManager.removeAllNotifications(of: tempPetName)
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
        PetListView()
            .environment(\.managedObjectContext, preview)
    }
}
