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

    enum Step: Hashable, CaseIterable {
        case name
        case birthday
        case kindAndImage
        case notifications
    }
    
    @Environment(\.notification) private var notificationManager: NotificationManager

    @Environment(\.modelContext) private var modelContext

    @Environment(\.dismiss) private var dismiss
    
    @State private var pet: Pet = .init()
    @State private var model: Model = .init()

    // Navigation
    @State private var path: [Step] = [] // empty path = first step

    private var currentStep: Step {
        path.last ?? .name
    }
    
    private var currentStepIndex: Int {
        Step.allCases.firstIndex(of: currentStep) ?? 0
    }

    private var progressValue: Double {
        Double(currentStepIndex + 1)
    }

    var body: some View {
        NavigationStack {
            stepContainer
                .navigationTitle(.addPet)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar { leadingToolbar; trailingNextOrSave }
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
        .overlay(alignment: .top) {
            progressView
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
    var stepContainer: some View {
        stepView(for: currentStep)
            .padding(.horizontal, .spacing20)
            .id(currentStep)
            .animation(.default, value: currentStep)
    }

    @ViewBuilder
    func stepView(for step: Step) -> some View {
        switch step {
        case .name:
            PetNameTextField(model: $model)
        case .birthday:
            PetBirthday(model: $model)
        case .kindAndImage:
            PetImageSelection(model: $model)
        case .notifications:
            NotificationSelect(model: $model)
        }
    }
    
    var progressView: some View {
        HStack {
            Spacer()
            ProgressView(value: progressValue, total: Double(Step.allCases.count))
                .tint(.label)
                .frame(width: .customProgressWidth)
                .animation(.spring(), value: progressValue)
            Spacer()
        }
        .offset(y: progressOffset)
    }
    
    var progressOffset: CGFloat {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
                .customProgressOffset - 10
        case .portrait, .portraitUpsideDown:
                .customProgressOffset
        default:
                .customProgressOffset
        }
    }
}

// MARK: - Toolbars
private extension AddPet {
    @ToolbarContentBuilder
    var leadingToolbar: some ToolbarContent {
        if currentStep == .name {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: dismiss.callAsFunction) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    _ = path.popLast()
                } label: {
                    Label(.back, systemImage: "chevron.left")
                }
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
                    Text(.save)
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

private extension CGFloat {
    static let customProgressWidth: Self = 80
    static let customProgressOffset: Self = 80
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
