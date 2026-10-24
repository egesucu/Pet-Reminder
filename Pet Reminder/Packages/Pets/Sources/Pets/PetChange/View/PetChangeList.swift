//
//  PetChangeList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Reminders
import SwiftUI
import SwiftData
import OSLog
import Shared
import SharedUI
#if DEBUG
import PreviewSupport
#endif

@MainActor
public struct PetChangeList: View {

    public init() {}

    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var isEditing = false
    @State private var selectedPet: Pet = .init()
    @State private var showSelectedPet = false

    var showEditButton: Bool {
        pets.isNotEmpty
    }

    public var body: some View {
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
                            Label {
                                Text(isEditing ? SharedStrings.done : SharedStrings.edit)
                            } icon: {
                                Image(systemName: isEditing ? "checkmark" : "pencil")
                            }
                                .animation(.bouncy, value: isEditing)
                        }
                    }

                }

            }
            .navigationTitle(Text(SharedStrings.chooseFriend))
        }
        .sheet(isPresented: $showSelectedPet, onDismiss: deselectPet) {
            ChangePetDetails(pet: $selectedPet, notificationManager: notificationManager)
                .presentationCornerRadius(.sheetCornerRadius25)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView(
                    SharedStrings.resource("pet_no_pet"),
                    systemImage: "pawprint.circle"
                )
            }
        }
    }

    @ContentBuilder
    private var petList: some View {
        LazyVGrid(columns: gridColumns, spacing: .spacing20) {
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
                            Label(SharedStrings.resource("Delete \(pet.name)"), systemImage: "trash.fill")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(.red, in: Circle())
                                .overlay {
                                    Circle()
                                        .stroke(Color(uiColor: .systemBackground), lineWidth: 3)
                                }
                                .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .offset(x: 8, y: -8)
                    }
                }
                .onLongPressGesture(perform: setEditMode)
                .padding(.top, .spacing20)
                .padding(.leading, .spacing20)
            }
        }
    }

    private var gridColumns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: .spacing20), count: count)
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
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PetChangeList()
            .modelContainer(PreviewData.previewContainer)
            .notification(NotificationManager())
    }
}
#endif
