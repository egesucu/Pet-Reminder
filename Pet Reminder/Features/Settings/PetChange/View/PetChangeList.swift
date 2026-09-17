//
//  PetChangeList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared

struct PetChangeList: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.notification) private var notificationManager: NotificationManager

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var isEditing = false
    @State private var selectedPet: Pet = .init()
    @State private var showSelectedPet = false

    var showEditButton: Bool {
        pets.isNotEmpty
    }

    var body: some View {
        VStack {
            ScrollView {
                petList

            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if showEditButton {
                        Button {
                            isEditing.toggle()
                        } label: {
                            Text(isEditing ? .done : .edit)
                                .animation(.bouncy, value: isEditing)
                        }
                    }

                }

            }
            .navigationTitle(Text(.chooseFriend))
        }
        .sheet(isPresented: $showSelectedPet, onDismiss: deselectPet) {
            ChangePetDetails(pet: $selectedPet)
                .presentationCornerRadius(.sheetCornerRadius25)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView(
                    "pet_no_pet",
                    systemImage: "pawprint.circle"
                )
            }
        }
    }

    @ContentBuilder
    private var petList: some View {
        LazyVGrid(columns: [.init(), .init()]) {
            ForEach(pets, id: \.name) { pet in
                ZStack(alignment: .topTrailing) {
                    Button {
                        isEditing = false
                        selectedPet = pet
                        showSelectedPet = true
                    } label: {
                        VStack {
                            CircleImage(
                                avatarSize: .avatar120,
                                imageData: pet.image,
                                kind: pet.kind
                            )
                            .modifier(WiggleModifier(isEnabled: isEditing))
                            Text(pet.name)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(pet.name))
                    if isEditing {
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await deletePet(pet: pet)
                                    isEditing = false
                                } catch {
                                    Logger.pets.error("Failed to delete pet: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Label("Delete \(pet.name)", systemImage: "xmark.circle.fill")
                                .labelStyle(.iconOnly)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                        }
                        .tint(.red)
                    }
                }
                .onLongPressGesture(perform: setEditMode)
                .padding(.top, .spacing20)
                .padding(.leading, .spacing20)
            }
        }
    }

    private func deselectPet() {
        selectedPet = .init()
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

#if DEBUG
#Preview {
    NavigationStack {
        PetChangeList()
            .modelContainer(DataController.previewContainer)
            .notification(NotificationManager.shared)
    }
}
#endif
