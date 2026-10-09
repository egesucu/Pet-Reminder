//
//  ChangePetDetails.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
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

struct ChangePetDetails: View {

    @Binding var pet: Pet
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var manager: PetDataManager

    init(pet: Binding<Pet>, notificationManager: NotificationManager) {
        self._pet = pet
        self._manager = State(initialValue: PetDataManager(notificationManager: notificationManager))
    }

    @State private var showError = false
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var showManagerErrorAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                switch manager.pageState {
                case .loading:
                    ProgressView()
                        .frame(width: .avatar200, height: .avatar200)
                        .tint(.accent)
                case .loaded(let pet):
                    petDetailView(pet)
                case .failed:
                    EmptyView()
                }
            }
            .navigationTitle(pet.name)
            .task {
                manager.loadPet(for: pet, dismiss: dismiss.callAsFunction)
                await manager.loadReminderTimes()
                isLoading = false
            }
            .disabled(isLoading || isSaving)
            .alert(SharedStrings.nameExistError, isPresented: $showError) {
                Button(role: .confirm, action: { })
            }
            .alert(isPresented: $showManagerErrorAlert) {
                Alert(
                    title: Text(SharedStrings.errorTitle),
                    message: Text(manager.lastErrorMessage ?? String(localized: SharedStrings.unknownError)),
                    dismissButton: .default(Text(SharedStrings.ok))
                )
            }
            .onChange(of: manager.lastErrorMessage) {
                showManagerErrorAlert = manager.lastErrorMessage != nil
            }
        }
    }

    @ContentBuilder
    func petImageView(_ pet: Pet) -> some View {
        HStack {
            if let photo = manager.petImage {
                preview(for: photo)
                    .frame(width: .avatar150, height: .avatar150)
                    .padding(.horizontal)
            } else {
                pet
                    .kind
                    .image
                    .frame(width: .avatar150, height: .avatar150)
                    .clipShape(.circle)
                    .padding(.horizontal)
            }
            if !manager.defaultSelected {
                PhotoImagePicker(
                    desiredTitle: SharedStrings.change,
                    photoData: $manager.petImageData,
                    desiredIcon: "photo.fill"
                )
                .padding(.vertical)
                .onChange(of: manager.petImageData) {
                    manager.loadImage()
                }
            }
        }
        .padding(.bottom, .spacing8)
    }

    func preview(for image: UIImage) -> some View {
        VStack(spacing: .spacing16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: .radius10))
                .glassEffect(.identity)

            Button(role: .destructive, action: manager.removePhoto) {
                Text(SharedStrings.resource("Delete Photo"))
            }
            .buttonStyle(.glass)
            .tint(.red)
        }
    }

    @ContentBuilder
    func petDetailView(_ pet: Pet) -> some View {
        Group {
            if horizontalSizeClass == .regular {
                if #available(iOS 27.1, *) {
                    ArrangementView {
                        photoPane(for: pet)
                    } secondary: {
                        detailsForm
                    }
                    .arrangementViewStyle(.split)
                } else {
                    HStack(spacing: .zero) {
                        photoPane(for: pet)
                        Divider()
                        detailsForm
                            .frame(maxWidth: .infinity)
                    }
                }
            } else {
                ScrollView {
                    photoEditor(for: pet)
                    detailsForm
                        .frame(minHeight: .editFormMinHeight500)
                }
            }
        }
        .toolbar(content: toolbar)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    func photoPane(for pet: Pet) -> some View {
        ScrollView {
            photoEditor(for: pet)
                .padding(.spacing20)
        }
        .frame(maxWidth: .infinity)
    }

    func photoEditor(for pet: Pet) -> some View {
        VStack {
            petImageView(pet)

            Toggle(isOn: $manager.defaultSelected) {
                Text(SharedStrings.defaultPhotoLabel)
            }
            .tint(.accent)
            .onChange(of: manager.defaultSelected) {
                if manager.defaultSelected {
                    manager.removePhoto()
                }
            }
            .padding()

            Text(SharedStrings.photoUploadDetailTitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }

    var detailsForm: some View {
        Form {
            personalDetailsView
            notificationSelectionView
        }
    }

    @MainActor var personalDetailsView: some View {
        Section {
            HStack {
                Text(SharedStrings.name)
                    .bold()
                TextField(text: $manager.name) {
                    Text(SharedStrings.tapToChangeText)
                }
            }

            HStack {
                Text(SharedStrings.petBreedTitle)
                    .bold()
                TextField(text: $manager.breed) {
                    Text(SharedStrings.tapToChangeText)
                }
            }

            DatePicker(
                selection: $manager.birthday,
                displayedComponents: .date
            ) {
                Text(SharedStrings.birthdayTitle)
                    .bold()
            }

            Picker(selection: $manager.kind) {
                ForEach(Kind.allCases, id: \.rawValue) { kind in
                    Text(kind.localizedName)
                        .tag(kind)
                }
            } label: {
                Text(SharedStrings.petKindText)
            }
            .pickerStyle(.segmented)
            .onChange(of: manager.kind) {
                manager.loadImage()
            }
        }
    }

    @ContentBuilder
    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task {
                    await save()
                }
            } label: {
                Label(SharedStrings.save, systemImage: "checkmark")
            }
            .tint(.accent)
        }
        ToolbarItem(placement: .cancellationAction) {
            Button(action: cancel) {
                Label(SharedStrings.cancelTitle, systemImage: "xmark")
            }
            .tint(.red)
        }
    }

    var notificationSelectionView: some View {
        Section {
            notificationPickerView
            notificationDetailsView
        }
    }

    var notificationPickerView: some View {
        VStack {
            Picker(selection: $manager.selection) {
                Text(SharedStrings.feedSelectionBoth)
                    .tag(FeedSelection.both)
                Text(SharedStrings.feedSelectionMorning)
                    .tag(FeedSelection.morning)
                Text(SharedStrings.feedSelectionEvening)
                    .tag(FeedSelection.evening)
            } label: {
                Text(SharedStrings.feedTimeTitle)
            }
            .pickerStyle(.segmented)
        }
    }

    @ContentBuilder var notificationDetailsView: some View {
        switch manager.selection {
        case .both:
            morningView
            eveningView
        case .morning:
            morningView
        case .evening:
            eveningView
        }
    }

    var eveningView: some View {
        DatePicker(
            selection: $manager.eveningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text(SharedStrings.feedSelectionEvening)
        }
    }

    var morningView: some View {
        DatePicker(
            selection: $manager.morningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text(SharedStrings.feedSelectionMorning)
        }
    }

    private func nameCanBeSaved() -> Bool {
        manager.nameCanBeSaved(for: pet, among: pets)
    }

    private func saveName() {
        if nameCanBeSaved() {
            manager.name = Pet.cleanedName(for: manager.name)
            pet.name = manager.name
        } else {
            manager.name = pet.name
            showError = true
        }
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        manager.lastErrorMessage = nil
        let scheduleChanged = manager.scheduleChanged
        let oldName = pet.name

        if pet.name != manager.name {
            saveName()
        }

        guard showError == false else {
            return
        }

        updatePetDetails()

        if pet.hasChanges {
            do {
                try modelContext.save()
                Logger().info("Pet Data has been updated")
            } catch {
                modelContext.rollback()
                Logger().error(
                    "Unknown error occurred while updating the pet. \(error.localizedDescription)"
                )
                manager.lastErrorMessage = String(localized: SharedStrings.petSaveFailed)
                return
            }
        }

        do {
            try await manager.notificationManager.renameNotifications(
                from: oldName,
                to: pet.name
            )
            await manager.changeBirthday()

            if scheduleChanged {
                await manager.changeNotification()
            }

            guard manager.lastErrorMessage == nil else {
                return
            }
            dismiss()
        } catch {
            Logger.notifications.error(
                "Failed to rename notifications: \(error.localizedDescription)"
            )
            manager.lastErrorMessage = String(localized: SharedStrings.notificationDailyUpdateFailed)
        }
    }

    private func updatePetDetails() {
        pet.breed = manager.breed.isEmpty ? nil : manager.breed
        pet.image = manager.petImageData
        pet.kind = manager.kind
        pet.birthday = manager.birthday
        pet.feedSelection = manager.selection
    }

    private func cancel() {
        manager.cancel(for: pet)
        dismiss()
    }
}

#if DEBUG
#Preview {
    ChangePetDetails(pet: .constant(.preview), notificationManager: NotificationManager())
        .modelContainer(PreviewData.previewContainer)
        .environment(\.locale, .init(identifier: "tr"))
}
#endif

extension View {
    func wiggling() -> some View {
        modifier(WiggleModifier())
    }
}
