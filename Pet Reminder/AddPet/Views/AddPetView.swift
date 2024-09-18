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

struct AddPetView: View {

    @State private var viewModel: AddPetViewModel

    @State private var position = 0
    @State private var feedTime: FeedSelection = .both
    @State private var nameIsFilledCorrectly = false
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.modelContext)
    private var modelContext

    init(
        viewModel: AddPetViewModel
    ) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    PetNameTextField(
                        name: $viewModel.name,
                        nameIsFilledCorrectly: $nameIsFilledCorrectly
                    )
                        .padding()
                    PetBirthdayView(birthday: $viewModel.birthday)
                        .padding()
                    PetImageView(
                        selectedImageData: $viewModel.selectedImageData
                    )
                        .padding()
                    NotificationSelectView(dayType: $feedTime)
                        .padding()
                    PetNotificationSelectionView(
                        dayType: $feedTime,
                        morningFeed: $viewModel.morningFeed,
                        eveningFeed: $viewModel.eveningFeed
                    )
                        .padding()
                    saveButton()
                }
            }
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func saveButton() -> some View {
        Button("Save") {
            Task {
                let pet = await viewModel.savePet()
                modelContext.insert(pet)
                dismiss()
            }
        }
        .buttonStyle(.bordered)
        .disabled(!nameIsFilledCorrectly)
    }
}

#Preview {
    AddPetView(
        viewModel: .init(notificationManager: .init())
    )
}
