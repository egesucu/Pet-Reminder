//
//  AddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import SwiftData
import Shared
import SFSafeSymbols

struct AddPetView: View {

    enum Step: Hashable {
        case name
        case birthday
        case kindAndImage
        case notifications
    }

    @State private var pet: Pet = .init()
    @State private var addPet: AddPet = .init()

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // Navigation
    @State private var path: [Step] = [] // empty path = first step

    private var currentStep: Step {
        path.last ?? .name
    }

    var body: some View {
        NavigationStack(path: $path) {
            stepView(for: .name)
                .navigationTitle("Add Pet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { leadingCancel; trailingNextOrSave }
                .navigationDestination(for: Step.self) { step in
                    stepView(for: step)
                        .navigationBarBackButtonHidden(true)
                        .toolbar { leadingBack; trailingNextOrSave }
                }
        }
        .sensoryFeedback(.error, trigger: addPet.saveFailed)
        .sensoryFeedback(.success, trigger: addPet.saveSuccess)
        .onChange(of: addPet.selectedImageData) {
            pet.image = addPet.selectedImageData
        }
        .alert(.saveFailed, isPresented: $addPet.saveFailed) {
            Button(.ok, action: dismiss.callAsFunction)
                .tint(Color.red)
            Button("Retry", action: save)
                .tint(Color.label)
        }
        .alert("Save Successful", isPresented: $addPet.saveSuccess) {
            Button(.ok, action: dismiss.callAsFunction)
                .tint(Color.label)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var leadingCancel: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel, action: dismiss.callAsFunction) {
                Image(systemSymbol: .xmark)
                    .foregroundStyle(.red)
            }
        }
    }

    @ToolbarContentBuilder
    private var leadingBack: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                _ = path.popLast()
            } label: {
                Label("Back", systemSymbol: .chevronLeft)
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingNextOrSave: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if currentStep == .notifications {
                    save()
                } else {
                    goNext()
                }
            } label: {
                if currentStep == .notifications {
                    Label("Save", systemSymbol: addPet.petCanBeSaved ? .squareAndArrowDownFill : .squareAndArrowDown)
                } else {
                    Label("Next", systemSymbol: .arrowRight)
                }
            }
            .disabled(currentStep == .name && !addPet.petCanBeSaved)
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private func stepView(for step: Step) -> some View {
        switch step {
        case .name:
            PetNameTextField(
                name: $pet.name,
                nameIsValid: $addPet.nameIsValid,
                petExists: $addPet.petExists
            )
            .padding(.horizontal)

        case .birthday:
            PetBirthdayView(birthday: $pet.birthday)
                .padding(.horizontal)

        case .kindAndImage:
            VStack(spacing: 20) {
                Text(.petKindText).font(.headline).foregroundStyle(.primary)
                Picker(selection: $pet.type) {
                    ForEach(PetType.allCases, id: \.self) { type in
                        Text(verbatim: type.localizedName)
                    }
                } label: {
                    Text(.petKindText)
                }
                .pickerStyle(.segmented)

                PetImageView(
                    selectedImageData: $addPet.selectedImageData,
                    petType: $pet.type
                )
            }
            .padding(.horizontal)

        case .notifications:
            VStack(spacing: 10) {
                NotificationSelectView(feedSelection: $addPet.feedSelection)
                PetNotificationSelectionView(
                    feedSelection: $addPet.feedSelection,
                    morningFeed: $addPet.morningFeed,
                    eveningFeed: $addPet.eveningFeed
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Nav helpers

    private func goNext() {
        switch currentStep {
        case .name:
            path.append(.birthday)
        case .birthday:
            path.append(.kindAndImage)
        case .kindAndImage:
            path.append(.notifications)
        case .notifications:
            break
        }
    }

    // MARK: - Save

    private func save() {
        Task {
            await persistPet()
        }
    }

    @MainActor
    private func persistPet() async {
        pet.name = pet.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard addPet.petCanBeSaved, pet.name.isNotEmpty else {
            // bounce back to first step if somehow reached here
            path = []
            return
        }

        pet.feedSelection = addPet.feedSelection
        pet.image = addPet.selectedImageData

        if pet.createdAt == nil {
            pet.createdAt = .now
        }

        do {
            try await createNotifications()
            modelContext.insert(pet)
            try modelContext.save()
            addPet.saveSuccess = true
        } catch {
            Logger.pets.error("Could not save the pet: \(error.localizedDescription)")
            addPet.saveFailed = true
            // Optionally take user back to name step to fix duplicates
            path = []
        }
    }

    private func createNotifications() async throws {
        switch addPet.feedSelection {
        case .both:
            try await notificationManager.createNotification(of: pet.name, with: .morning, date: addPet.morningFeed)
            try await notificationManager.createNotification(of: pet.name, with: .evening, date: addPet.eveningFeed)
        case .morning:
            try await notificationManager.createNotification(of: pet.name, with: .morning, date: addPet.morningFeed)
        case .evening:
            try await notificationManager.createNotification(of: pet.name, with: .evening, date: addPet.eveningFeed)
        }

        try await notificationManager.createNotification(of: pet.name, with: .birthday, date: pet.birthday)
    }
}

#if DEBUG

#Preview {
    AddPetView()
        .environment(NotificationManager.shared)
}

#endif
