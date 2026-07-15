//
//  ChangePetDetails.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared

struct ChangePetDetails: View {

    @Binding var pet: Pet
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Query(sort: \Pet.name) var pets: [Pet]

    @State private var manager = PetDataManager()

    @State private var showError = false
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
            .onAppear {
                manager.loadPet(for: pet, dismiss: dismiss.callAsFunction)
            }
            .alert(.nameExistError, isPresented: $showError) {
                Button(role: .confirm, action: { })
            }
            .alert(isPresented: $showManagerErrorAlert) {
                Alert(
                    title: Text(.errorTitle),
                    message: Text(manager.lastErrorMessage ?? String(localized: .unknownError)),
                    dismissButton: .default(Text(.ok))
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
                    desiredTitle: LocalizedStringResource.change,
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
                Text("Delete Photo")
            }
            .buttonStyle(.glass)
            .tint(.red)
        }
    }

    @ContentBuilder
    func petDetailView(_ pet: Pet) -> some View {
        ScrollView {
            petImageView(pet)

            Toggle(isOn: $manager.defaultSelected) {
                Text(.defaultPhotoLabel)
            }
            .tint(.accent)
            .onChange(of: manager.defaultSelected) {
                if manager.defaultSelected {
                    manager.removePhoto()
                }
            }
            .padding()
            Text(.photoUploadDetailTitle)
                .font(.footnote)
                .foregroundStyle(Color(.systemGray2))
                .multilineTextAlignment(.center)
                .padding()
            Form {
                personalDetailsView
                notificationSelectionView
            }
            .frame(minHeight: .editFormMinHeight500)
        }
        .toolbar(content: toolbar)
        .background(Color(uiColor: .systemGroupedBackground))
    }

    @MainActor var personalDetailsView: some View {
        Section {
            HStack {
                Text(.name)
                    .bold()
                TextField(text: $manager.name) {
                    Text(.tapToChangeText)
                }
            }
            
            HStack {
                Text(.petBreedTitle)
                    .bold()
                TextField(text: $manager.breed) {
                    Text(.tapToChangeText)
                }
            }

            DatePicker(
                selection: $manager.birthday,
                displayedComponents: .date
            ) {
                Text(.birthdayTitle)
                    .bold()
            }

            Picker(selection: $manager.kind) {
                ForEach(Kind.allCases, id: \.rawValue) { kind in
                    Text(kind.localizedName)
                        .tag(kind)
                }
            } label: {
                Text(.petKindText)
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
            Button(action: save) {
                Text(.save)
                    .bold()
            }
            .tint(.accent)
        }
        ToolbarItem(placement: .cancellationAction) {
            Button(action: cancel) {
                Text(.cancelTitle)
                    .bold()
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
                Text(.feedSelectionBoth)
                    .tag(FeedSelection.both)
                Text(.feedSelectionMorning)
                    .tag(FeedSelection.morning)
                Text(.feedSelectionEvening)
                    .tag(FeedSelection.evening)
            } label: {
                Text(.feedTimeTitle)
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
            Text(.feedSelectionEvening)
        }
    }

    var morningView: some View {
        DatePicker(
            selection: $manager.morningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text(.feedSelectionMorning)
        }
    }

    private func nameCanBeSaved() -> Bool {
        let petNames = pets.map { $0.name }
        let isUniqueName = !petNames.contains(where: { $0 == manager.name })
        return isUniqueName
    }

    private func saveName() {
        if nameCanBeSaved() {
            pet.name = manager.name
        } else {
            manager.name = pet.name
            showError = true
        }
    }

    private func save() {
        if pet.name != manager.name {
            saveName()
        }

        // If we have a unique name error, don't continue saving
        if showError {
            return
        }
        
        // Making sure to not save a breed name as empty string.
        if pet.breed != manager.breed {
            pet.breed = manager.breed.isEmpty ? nil : manager.breed
        }

        if pet.image != manager.petImageData {
            pet.image = manager.petImageData
        }

        if pet.kind != manager.kind {
            pet.kind = manager.kind
        }

        if pet.birthday != manager.birthday {
            pet.birthday = manager.birthday
        }

        /// This notification might be missing from previous data,
        /// so it's best to run this even if there's no birthday change.
        Task {
            await manager.changeBirthday()
        }

        if pet.feedSelection != manager.selection {
            pet.feedSelection = manager.selection
            Task {
                await manager.changeNotification()
            }
        }

        if pet.hasChanges {
            do {
                try modelContext.save()
                Logger().info("Pet Data has been updated")
            } catch {
                Logger().error(
                    "Unknown error occurred while updating the pet. \(error.localizedDescription)"
                )
                manager.lastErrorMessage = String(localized: .petSaveFailed)
                return
            }
        }
        dismiss()
    }

    private func cancel() {
        manager.cancel(for: pet)
        dismiss()
    }
}

#if DEBUG
#Preview {
    ChangePetDetails(pet: .constant(.preview))
        .modelContainer(DataController.previewContainer)
        .environment(\.locale, .init(identifier: "tr"))
}
#endif

extension View {
    func wiggling() -> some View {
        modifier(WiggleModifier())
    }
}
