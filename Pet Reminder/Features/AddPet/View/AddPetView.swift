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

struct AddPetView: View {

    enum Step: Hashable {
        case name
        case birthday
        case kindAndImage
        case notifications
    }
    
    @Environment(NotificationManager.self)
    private var notificationManager: NotificationManager

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    @State private var pet: Pet = .init()
    @State private var addPet: AddPet = .init()

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
        .sensoryFeedback(.error, trigger: addPet.saveState == .failure)
        .sensoryFeedback(.success, trigger: addPet.saveState == .success)
        .onChange(of: addPet.selectedImageData) {
            pet.image = addPet.selectedImageData
        }
        .alert(.saveFailed, isPresented: Binding(
            get: { addPet.saveState == .failure },
            set: { if !$0 { addPet.saveState = .none } }
        )) {
            Button(.ok) {
                addPet.saveState = .none
                dismiss()
            }
            .tint(Color.red)
            Button("Retry") {
                addPet.saveState = .none
                save()
            }
            .tint(Color.label)
        }
        .alert("Save Successful", isPresented: Binding(
            get: { addPet.saveState == .success },
            set: { if !$0 { addPet.saveState = .none } }
        )) {
            Button(.ok) {
                addPet.saveState = .none
                dismiss()
            }
            .tint(Color.label)
        }
    }
}


// MARK: - Subviews
private extension AddPetView {
    @ViewBuilder
    func stepView(for step: Step) -> some View {
        switch step {
        case .name:
            PetNameTextField(addPet: $addPet)
                .padding(.horizontal, PRSpacing.spacing20)

        case .birthday:
            PetBirthdayView(addPet: $addPet)
                .padding(.horizontal, PRSpacing.spacing20)

        case .kindAndImage:
            VStack(spacing: PRSpacing.spacing20) {
                Text(.petKindText).font(.headline).foregroundStyle(.primary)
                Picker(selection: $pet.type) {
                    ForEach(PetType.allCases, id: \.self) { type in
                        Text(verbatim: type.localizedName)
                    }
                } label: {
                    Text(.petKindText)
                }
                .pickerStyle(.segmented)

                PetImageView(addPet: $addPet)
            }
            .padding(.horizontal, PRSpacing.spacing20)

        case .notifications:
            VStack(spacing: PRSpacing.spacing8) {
                NotificationSelectView(addPet: $addPet)
                PetNotificationSelectionView(addPet: $addPet)
            }
            .padding(.horizontal, PRSpacing.spacing20)
        }
    }

}

// MARK: - Toolbars
private extension AddPetView {
    @ToolbarContentBuilder
    var leadingCancel: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel, action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
            }
        }
    }

    @ToolbarContentBuilder
    var leadingBack: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                _ = path.popLast()
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
        }
    }

    @ToolbarContentBuilder
    var trailingNextOrSave: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if currentStep == .notifications {
                    save()
                } else {
                    goNext()
                }
            } label: {
                if currentStep == .notifications {
                    Label("Save", systemImage: addPet.petCanBeSaved ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                } else {
                    Label("Next", systemImage: "arrow.right")
                }
            }
            .disabled(currentStep == .name && !addPet.petCanBeSaved)
        }
    }
}

// MARK: - Actions
private extension AddPetView {
    // MARK: - Nav helpers

    func goNext() {
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

    func save() {
        Task {
            await persistPet()
        }
    }

    func persistPet() async {
        pet.name = pet.name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard addPet.petCanBeSaved, addPet.name.isNotEmpty else {
            // bounce back to first step if somehow reached here
            path = []
            return
        }

        pet.name = addPet.name
        pet.type = addPet.type
        pet.birthday = addPet.birthday
        pet.feedSelection = addPet.feedSelection
        pet.image = addPet.selectedImageData

        if pet.createdAt == nil {
            pet.createdAt = .now
        }

        do {
            try await createNotifications()
            modelContext.insert(pet)
            try modelContext.save()
            addPet.saveState = .success
        } catch {
            Logger.pets.error("Could not save the pet: \(error.localizedDescription)")
            addPet.saveState = .failure
            // Optionally take user back to name step to fix duplicates
            path = []
        }
    }

    func createNotifications() async throws {
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
    Button("Tap me") {
        // Tapped
    }.sheet(isPresented: .constant(true)) {
        AddPetView()
            .environment(NotificationManager.shared)
    }
}
#endif
