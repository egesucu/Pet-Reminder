//
//  PetChangeListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import SharedModels

public struct PetChangeListView: View {

    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.undoManager) var undoManager
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var showUndoButton = false
    @State private var buttonTimer: (any DispatchSourceTimer)?
    @State private var time = 0
    @State private var isEditing = false
    @State private var selectedPet: Pet?
    @State private var showSelectedPet = false
    @State private var showEditButton = false
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    public var body: some View {
        VStack {
            ScrollView {
                petList
                    .onTapGesture {
                        Logger
                            .pets
                            .info("Surface tapped.")
                        isEditing = false
                        Logger
                            .pets
                            .info("Editing status: \(isEditing)")
                    }
            }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if showUndoButton {
                            Button {
                                modelContext.undoManager?.undo()
                                showUndoButton = false
                            } label: {
                                Image(systemName: "arrow.uturn.backward.circle")
                            }
                        }
                        if showEditButton {
                            Button {
                                isEditing.toggle()
                            } label: {
                                Text(isEditing ? "Done" : "Edit")
                            }
                        }

                    }

                }
            .navigationTitle(Text("Choose Friend"))
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView("pet_no_pet", systemImage: "pawprint.circle")
            }
        }
    }

    @ViewBuilder
    private var petList: some View {
        LazyVGrid(columns: [.init(), .init()]) {
            ForEach(pets, id: \.name) { pet in
                VStack {
                    if isEditing {
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                ESImageView(data: pet.image)
                                    .clipShape(Circle())
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 60)
                                            .stroke(
                                                defineColor(pet: pet),
                                                lineWidth: 5
                                            )
                                    )
                                    .wiggling()
                                Text(pet.name)
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
                            .frame(width: 120, height: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 60)
                                    .stroke(
                                        defineColor(pet: pet),
                                        lineWidth: 5
                                    )
                            )

                        Text(pet.name)
                    }

                }
                .onTapGesture {
                    selectedPet = pet
                    showSelectedPet.toggle()
                    Logger
                        .pets
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
        let tempPetName = pet.name
        if pet == selectedPet {
            selectedPet = nil
        }
        modelContext.delete(pet)
        showUndoButton.toggle()
        
        buttonTimer?.cancel()
        buttonTimer = nil
        
        time = 0
        
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: 1.0)
        
        timer.setEventHandler {
            Task { @MainActor in
                if time == 10 {
                    withAnimation {
                        self.notificationManager?.removeAllNotifications(of: tempPetName)
                        showUndoButton = false
                        timer.cancel()
                        self.buttonTimer = nil
                    }
                } else {
                    time += 1
                }
            }
        }
        
        buttonTimer = timer
        timer.resume()
    }

    private func defineColor(pet: Pet) -> Color {
        selectedPet?.name == pet.name ? Color.yellow : Color.clear
    }
}

#Preview {
    NavigationStack {
        PetChangeListView()
            .modelContainer(DataController.previewContainer)
            .environment(NotificationManager())
    }
}
