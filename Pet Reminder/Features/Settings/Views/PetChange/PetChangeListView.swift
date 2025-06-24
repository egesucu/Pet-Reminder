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
import Shared

struct PetChangeListView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    @Environment(NotificationManager.self)
    private var notificationManager: NotificationManager
    
    @Query(sort: \Pet.name) var pets: [Pet]
    
    @State private var showUndoButton = false
    @State private var buttonTimer: (any DispatchSourceTimer)?
    @State private var time = 0
    @State private var isEditing = false
    @State private var selectedPet: Pet?
    @State private var showSelectedPet = false
    @State private var showEditButton = false
    
    var body: some View {
        VStack {
            ScrollView {
                petList
                    .onTapGesture {
                        Logger
                            .pets
                            .info("\("Surface tapped.")")
                        isEditing = false
                        Logger
                            .pets
                            .info("Editing status: \(isEditing)")
                    }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if showEditButton {
                        Button {
                            isEditing.toggle()
                        } label: {
                            Text(.done)
                        }
                    }
                    
                }
                
            }
            .navigationTitle(Text(.chooseFriend))
            .navigationBarTitleTextColor(.accent)
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
                                if let imageData = pet.image,
                                   let image = UIImage(data: imageData) {
                                    Image(uiImage: image)
                                        .petImageStyle(useShadows: true)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 60)
                                                .stroke(
                                                    defineColor(pet: pet),
                                                    lineWidth: 5
                                                )
                                        )
                                        .wiggling()
                                } else {
                                    Image(.generateDefaultData(type: pet.type))
                                        .petImageStyle()
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 60)
                                                .stroke(
                                                    defineColor(pet: pet),
                                                    lineWidth: 5
                                                )
                                        )
                                        .wiggling()
                                }
                                
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
                        .opacity(isEditing ? 1 : 0)
                        .scaleEffect(isEditing ? 1 : 0.95)
                        .animation(.easeInOut(duration: 0.3), value: isEditing)
                    } else {
                        if let imageData = pet.image,
                           let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .petImageStyle(useShadows: true)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(
                                            defineColor(pet: pet),
                                            lineWidth: 5
                                        )
                                )
                        } else {
                            Image(.generateDefaultData(type: pet.type))
                                .petImageStyle()
                                .frame(width: 120, height: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(
                                            defineColor(pet: pet),
                                            lineWidth: 5
                                        )
                                )
                        }
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
                .sheet(isPresented: $showSelectedPet, onDismiss: deselectPet, content: {
                    PetChangeView(pet: $selectedPet)
                        .presentationCornerRadius(25)
                        .presentationDragIndicator(.hidden)
                        .interactiveDismissDisabled()
                })
                .onLongPressGesture(perform: setEditMode)
                .padding([.top, .leading])
            }
        }
    }
    
    private func deselectPet() {
        selectedPet = nil
    }
    
    private func setEditMode() {
        isEditing.toggle()
    }
    
    func deletePet(pet: Pet) {
        notificationManager.removeAllNotifications(of: pet.name)
        if pet == selectedPet {
            deselectPet()
        }
        withAnimation {
            modelContext.delete(pet)
        }
    }
    
    private func defineColor(pet: Pet) -> Color {
        selectedPet == pet
        ? Color.yellow
        : Color.clear
    }
}

#Preview {
    NavigationStack {
        PetChangeListView()
            .modelContainer(DataController.previewContainer)
            .environment(NotificationManager.shared)
    }
}
