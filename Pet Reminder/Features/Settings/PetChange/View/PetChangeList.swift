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
                                        .frame(width: .avatar120, height: .avatar120)
                                        .wiggling()
                                } else {
                                    Image(.generateDefaultData(kind: pet.kind))
                                        .petImageStyle()
                                        .frame(width: .avatar120, height: .avatar120)
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
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: .icon24))
                                    .foregroundStyle(.red)
                                    .offset(x: .deleteBadgeX, y: 0)
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
                                .frame(width: .avatar120, height: .avatar120)
                        } else {
                            Image(.generateDefaultData(kind: pet.kind))
                                .petImageStyle()
                                .frame(width: .avatar120, height: .avatar120)
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
                        .info("PR: Pet Selected: \(selectedPet.name)")
                }
                .sheet(isPresented: $showSelectedPet, onDismiss: deselectPet, content: {
                    ChangePetDetails(pet: $selectedPet)
                        .presentationCornerRadius(.sheetCornerRadius25)
                        .presentationDragIndicator(.hidden)
                        .interactiveDismissDisabled()
                })
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
