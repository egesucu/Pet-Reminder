//
//  AddPet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import SwiftData
import Shared

struct AddPet: View {

    @Environment(\.notification) private var notificationManager: NotificationManager

    @Environment(\.modelContext) private var modelContext

    @Environment(\.dismiss) private var dismiss
    
    @State private var pet: Pet = .init()
    @State private var model: Model = .init()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacing24) {
                    PetNameTextField(model: $model)
                    PetBirthday(model: $model)
                    PetImageSelection(model: $model)
                    NotificationSelect(model: $model)
                    saveButton
                }
                .padding(.horizontal)
                .navigationTitle(.addPet)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { leadingToolbar }
            }
        }
        .sensoryFeedback(.error, trigger: model.saveState == .failure)
        .sensoryFeedback(.success, trigger: model.saveState == .success)
        .onChange(of: model.selectedImageData) {
            pet.image = model.selectedImageData
        }
        .alert(.saveFailed, isPresented: Binding(
            get: { model.saveState == .failure },
            set: { if !$0 { model.saveState = .none } }
        )) {
            Button(.ok) {
                model.saveState = .none
                dismiss()
            }
            .tint(Color.red)
            Button(.retry) {
                model.saveState = .none
                Task {
                    await persistPet()
                }
            }
            .tint(Color.label)
        }
        .alert(.saveSuccessful, isPresented: Binding(
            get: { model.saveState == .success },
            set: { if !$0 { model.saveState = .none } }
        )) {
            Button(.ok) {
                model.saveState = .none
                dismiss()
            }
            .tint(Color.label)
        }
    }
}

extension AddPet {
    /// Model backing the Add Pet flow.
    @Observable
    @MainActor
    class Model {
        
        /// Tracks the result of a save attempt.
        enum SaveState: Equatable {
            case none, success, failure
        }
        
        /// Entered pet name.
        var name: String
        /// Selected birthday for the pet.
        var birthday: Date = .now
        /// Selected pet kind.
        var kind: Kind = .dog
        /// Raw image data from the picker.
        var selectedImageData: Data?
        /// Which feed reminders are enabled.
        var feedSelection: FeedSelection
        /// Morning feed reminder time.
        var morningFeed: Date
        /// Evening feed reminder time.
        var eveningFeed: Date
        /// Whether the name currently passes validation.
        var nameIsValid: Bool
        /// Whether a pet with this name already exists.
        var petExists: Bool
        /// Result state for the last save attempt.
        var saveState: SaveState = .none
        
        /// Creates a new Add Pet model with configurable defaults.
        init(
            name: String = .empty,
            birthday: Date = .now,
            selectedImageData: Data? = nil,
            kind: Kind = .dog,
            feedSelection: FeedSelection = .both,
            morningFeed: Date = .eightAM,
            eveningFeed: Date = .eightPM,
            nameIsValid: Bool = false,
            petExists: Bool = false
        ) {
            self.name = name
            self.birthday = birthday
            self.kind = kind
            self.selectedImageData = selectedImageData
            self.feedSelection = feedSelection
            self.morningFeed = morningFeed
            self.eveningFeed = eveningFeed
            self.nameIsValid = nameIsValid
            self.petExists = petExists
        }
        
        /// Returns true when the pet can be saved.
        var petCanBeSaved: Bool {
            nameIsValid && !petExists
        }
    }
}

// MARK: - Toolbars
private extension AddPet {
    @ContentBuilder
    var leadingToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel, action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .foregroundStyle(.red)
            }
        }
    }

    @ContentBuilder
    var saveButton: some View {
        HStack {
            Spacer()
            
            Button(.save, systemImage: "square.and.arrow.down.fill", role: .confirm) {
                Task {
                    await persistPet()
                }
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
            .disabled(!model.petCanBeSaved)
            
            Spacer()
        }
    }
}

// MARK: - Actions
private extension AddPet {

    // MARK: - Save

    func persistPet() async {
        let cleanedName = Pet.cleanedName(for: model.name)

        guard model.petCanBeSaved, cleanedName.isNotEmpty else {
            return
        }

        model.name = cleanedName
        pet.name = cleanedName
        pet.kind = model.kind
        pet.birthday = model.birthday
        pet.feedSelection = model.feedSelection
        pet.image = model.selectedImageData

        if pet.createdAt == nil {
            pet.createdAt = .now
        }

        do {
            try await createNotifications()
            modelContext.insert(pet)
            try modelContext.save()
            model.saveState = .success
        } catch {
            Logger.pets.error("Could not save the pet: \(error.localizedDescription)")
            model.saveState = .failure
        }
    }

    func createNotifications() async throws {
        switch model.feedSelection {
        case .both:
            try await notificationManager.createNotification(of: pet.name, with: .morning, date: model.morningFeed)
            try await notificationManager.createNotification(of: pet.name, with: .evening, date: model.eveningFeed)
        case .morning:
            try await notificationManager.createNotification(of: pet.name, with: .morning, date: model.morningFeed)
        case .evening:
            try await notificationManager.createNotification(of: pet.name, with: .evening, date: model.eveningFeed)
        }

        try await notificationManager.createNotification(of: pet.name, with: .birthday, date: pet.birthday)
    }
}

private extension CGFloat {
    static let customProgressOffset: Self = 30
}

#if DEBUG
#Preview {
    Button("Tap me") {
        // Tapped
    }.sheet(isPresented: .constant(true)) {
        AddPet()
            .notification(NotificationManager.shared)
    }
}
#endif
