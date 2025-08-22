//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared

struct PetChangeView: View {

    @Binding var pet: Pet?
    @Environment(\.modelContext) var modelContext
    @State private var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss

    @State private var viewModel = PetChangeViewModel()

    var body: some View {
        NavigationStack {
            if let pet {
                VStack {
                    ScrollView {
                        HStack {
                            if let outputImageData = viewModel.outputImageData,
                               let selectedImage = UIImage(data: outputImageData) {
                                PetShowImageView(selectedImage: selectedImage, onImageDelete: viewModel.removeImage)
                                    .padding(.horizontal)
                            } else {
                                Image(.defaultOther)
                                    .frame(width: 200, height: 200)
                            }
                            if !viewModel.defaultPhotoOn {
                                PhotoImagePickerView(photoData: $viewModel.outputImageData)
                                    .padding(.vertical)
                            }
                        }
                        Toggle(isOn: $viewModel.defaultPhotoOn) {
                            Text(.defaultPhotoLabel)
                        }
                        .tint(Color.accentColor)
                        .onChange(of: viewModel.defaultPhotoOn, {
                            if viewModel.defaultPhotoOn {
                                viewModel.outputImageData = nil
                            }
                        })
                        .padding()
                        Text(.photoUploadDetailTitle)
                            .font(.footnote)
                            .foregroundStyle(Color(.systemGray2))
                            .multilineTextAlignment(.center)
                            .padding()
                        Form {
                            Section {
                                TextField(text: $viewModel.nameText) {
                                    Text(.tapToChangeText)
                                }
                                DatePicker(selection: $viewModel.birthday, displayedComponents: .date) {
                                    Text(.birthdayTitle)
                                }
                            }
                            Section {
                                pickerView
                                setupPickerView()
                            }
                        }
                        .frame(height: 400)
                    }
                }
                .navigationTitle(pet.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                try await viewModel.savePet(pet: pet)
                            }
                            dismiss()
                        } label: {
                            Text(.save)
                                .bold()
                        }
                        .tint(.accent)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text(.cancel)
                                .bold()
                        }
                        .tint(Color(uiColor: .systemRed))
                    }
                }
                .task {
                    await viewModel.getPetData(pet: pet)
                }
            }
        }
    }
    var pickerView: some View {
        VStack {
            Picker(selection: $viewModel.selection) {
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

    @ViewBuilder
    func setupPickerView() -> some View {
        switch viewModel.selection {
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
            selection: $viewModel.eveningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text(.feedSelectionEvening)
        }
    }

    var morningView: some View {
        DatePicker(
            selection: $viewModel.morningDate,
            displayedComponents: .hourAndMinute
        ) {
            Text(.feedSelectionMorning)
        }
    }

}

#Preview {
    PetChangeView(pet: .constant(.preview))
        .modelContainer(DataController.previewContainer)
}

extension View {
    func wiggling() -> some View {
        modifier(WiggleModifier())
    }
}
