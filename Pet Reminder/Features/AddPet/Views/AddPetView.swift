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

    @State private var position = 0
    @State private var pet: Pet = .init()
    @State private var selectedImageData: Data?

    @State private var feedSelection: FeedSelection = .both
    @State private var morningFeed: Date = .eightAM
    @State private var eveningFeed: Date = .eightPM

    @State private var nameIsValid = false
    @State private var petExists = false
    @State private var saveFailed = false
    @State private var saveSuccess = false

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    // Navigation
    @State private var path: [Step] = [] // empty path = first step

    var petCanBeSaved: Bool {
        nameIsValid && !petExists
    }

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
        .background(.ultraThinMaterial)
        .sensoryFeedback(.error, trigger: saveFailed)
        .sensoryFeedback(.success, trigger: saveSuccess)
        .alert(.saveFailed, isPresented: $saveFailed) {
            Button(.ok, action: dismiss.callAsFunction)
                .tint(Color.red)
            Button("Retry", action: save)
                .tint(Color.label)
        }
        .alert("Save Successful", isPresented: $saveSuccess) {
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
                    Label("Save", systemSymbol: petCanBeSaved ? .squareAndArrowDownFill : .squareAndArrowDown)
                } else {
                    Label("Next", systemSymbol: .arrowRight)
                }
            }
            .disabled(currentStep == .name && !petCanBeSaved)
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private func stepView(for step: Step) -> some View {
        switch step {
        case .name:
            PetNameTextField(
                name: $pet.name,
                nameIsValid: $nameIsValid,
                petExists: $petExists
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
                    selectedImageData: $selectedImageData,
                    petType: $pet.type
                )
            }
            .padding(.horizontal)

        case .notifications:
            VStack(spacing: 10) {
                NotificationSelectView(feedSelection: $feedSelection)
                PetNotificationSelectionView(
                    feedSelection: $feedSelection,
                    morningFeed: $morningFeed,
                    eveningFeed: $eveningFeed
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
        guard pet.name.isNotEmpty else {
            // bounce back to first step if somehow reached here
            path = []
            return
        }

        Task {
            pet.feedSelection = feedSelection
            modelContext.insert(pet)

            do {
                try await createNotifications()
                try modelContext.save()
                saveSuccess.toggle()
            } catch {
                Logger.pets.error("Could not save the pet: \(error.localizedDescription)")
                saveFailed.toggle()
                // Optionally take user back to name step to fix duplicates
                path = []
            }
        }
    }

    private func createNotifications() async throws {
        switch feedSelection {
        case .both:
            try await notificationManager.createNotification(of: pet.name, with: .morning, date: morningFeed)
            try await notificationManager.createNotification(of: pet.name, with: .evening, date: eveningFeed)
        case .morning:
            try await notificationManager.createNotification(of: pet.name, with: .morning, date: morningFeed)
        case .evening:
            try await notificationManager.createNotification(of: pet.name, with: .evening, date: eveningFeed)
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
