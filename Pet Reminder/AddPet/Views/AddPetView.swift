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
            TabView {
                PetNameTextField(
                    name: $viewModel.name,
                    nameIsFilledCorrectly: $nameIsFilledCorrectly
                )
                    .padding()
                PetBirthdayView(birthday: $viewModel.birthday)
                    .padding()
                
                VStack {
                    Text("Which kind of the Pet you've got?")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Picker(selection: $viewModel.petType) {
                        ForEach(PetType.allCases, id: \.self) {
                            Text($0.name)
                                .foregroundStyle(.white)
                        }
                    } label: {
                        Text("Which kind of the Pet you've got?")
                            .foregroundStyle(.white)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .colorMultiply(.white)
                    PetImageView(
                        selectedImageData: $viewModel.selectedImageData, petType: $viewModel.petType
                    )
                        .padding()
                }
                
                VStack {
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
            .tabViewStyle(.page(indexDisplayMode: .always))
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .tint(Color.white)
                        .bold()
                }
            }
            .background(
                Color.accent
            )
            .navigationTitle(
                Text("Setup")
            )
            .navigationBarTitleTextColor(.white)
        }
    }

    private func saveButton() -> some View {
        Button {
            Task {
                let pet = await viewModel.savePet()
                modelContext.insert(pet)
                dismiss()
            }
        } label: {
            Text("Save")
                .font(.title)
        }
        .tint(.white)
        .buttonStyle(.bordered)
        .disabled(!nameIsFilledCorrectly)
    }
}

#Preview {
    AddPetView(
        viewModel: .init(notificationManager: .init())
    )
}
