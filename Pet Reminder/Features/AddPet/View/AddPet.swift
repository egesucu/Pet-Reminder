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

    enum Step: Hashable {
        case name
        case birthday
        case kindAndImage
        case notifications
    }
    
    @Environment(\.notification)
    private var notificationManager: NotificationManager

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    @State private var pet: Pet = .init()
    @State private var model: Model = .init()

    // Navigation
    @State private var path: [Step] = [] // empty path = first step

    private var currentStep: Step {
        path.last ?? .name
    }

    var body: some View {
        NavigationStack(path: $path) {
            stepView(for: .name)
                .navigationTitle(.addPet)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { leadingCancel; trailingNextOrSave }
                .navigationDestination(for: Step.self) { step in
                    stepView(for: step)
                        .navigationBarBackButtonHidden(true)
                        .toolbar { leadingBack; trailingNextOrSave }
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
                save()
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
        enum SaveState {
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


// MARK: - Subviews
private extension AddPet {
    @ViewBuilder
    func stepView(for step: Step) -> some View {
        switch step {
        case .name:
            PetNameTextField(model: $model)
                .padding(.horizontal, .spacing20)

        case .birthday:
            PetBirthday(model: $model)
                .padding(.horizontal, .spacing20)

        case .kindAndImage:
            VStack(spacing: .spacing20) {
                Text(.petKindText).font(.headline).foregroundStyle(.primary)
                Picker(selection: $model.kind) {
                    ForEach(Kind.allCases, id: \.self) { kind in
                        Text(verbatim: kind.localizedName)
                    }
                } label: {
                    Text(.petKindText)
                }
                .pickerStyle(.segmented)

                PetImageSelection(model: $model)
            }
            .padding(.horizontal, .spacing20)

        case .notifications:
            VStack(spacing: .spacing8) {
                NotificationSelect(model: $model)
                PetNotificationSelection(model: $model)
            }
            .padding(.horizontal, .spacing20)
        }
    }

}

// MARK: - Toolbars
private extension AddPet {
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
                Label(.back, systemImage: "chevron.left")
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
                    Label(.save, systemImage: model.petCanBeSaved ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                } else {
                    Label(.next, systemImage: "arrow.right")
                }
            }
            .disabled(currentStep == .name && !model.petCanBeSaved)
        }
    }
}

// MARK: - Actions
private extension AddPet {
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

        guard model.petCanBeSaved, model.name.isNotEmpty else {
            // bounce back to first step if somehow reached here
            path = []
            return
        }

        pet.name = model.name
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
            // Optionally take user back to name step to fix duplicates
            path = []
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
