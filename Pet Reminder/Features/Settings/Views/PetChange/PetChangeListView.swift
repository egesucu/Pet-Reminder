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
import SFSafeSymbols

struct PetChangeListView: View {

    @Environment(\.modelContext)
    private var modelContext
    @Environment(NotificationManager.self)
    private var notificationManager: NotificationManager

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var isEditing = false
    @State private var selectedPet: Pet?
    @State private var showSelectedPet = false

    var showEditButton: Bool {
        pets.isNotEmpty
    }

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
                            Text(isEditing ? .done : .edit)
                                .animation(.bouncy)
                        }
                    }

                }

            }
            .navigationTitle(Text(.chooseFriend))
            .navigationBarTitleTextColor(.accent)
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView(
                    "pet_no_pet",
                    systemSymbol: .pawprintCircle
                )
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
                                        .petImageStyle()
                                        .frame(width: 120, height: 120)
                                        .wiggling()
                                } else {
                                    Image(.generateDefaultData(type: pet.type))
                                        .petImageStyle()
                                        .frame(width: 120, height: 120)
                                        .wiggling()
                                }

                                Text(pet.name)
                            }
                            Button {
                                Task {
                                    do {
                                        try await deletePet(pet: pet)
                                        withAnimation {
                                            isEditing = false
                                        }
                                    } catch {
                                        Logger.pets.error("Failed to delete pet: \(error.localizedDescription)")
                                    }
                                }
                            } label: {
                                Image(systemSymbol: .xmarkCircleFill)
                                    .font(.title)
                                    .foregroundStyle(.red)
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
                                .petImageStyle()
                                .frame(width: 120, height: 120)
                        } else {
                            Image(.generateDefaultData(type: pet.type))
                                .petImageStyle()
                                .frame(width: 120, height: 120)
                        }
                        Text(pet.name)
                    }

                }
                .onTapGesture {
                    isEditing = false
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

    func deletePet(pet: Pet) async throws {
        try await notificationManager.removeAllNotifications(of: pet.name)
        if pet == selectedPet {
            deselectPet()
        }
        withAnimation {
            modelContext.delete(pet)
        }
    }
}

#Preview {
    NavigationStack {
        PetChangeListView()
            .modelContainer(DataController.previewContainer)
            .environment(NotificationManager.shared)
    }
}
