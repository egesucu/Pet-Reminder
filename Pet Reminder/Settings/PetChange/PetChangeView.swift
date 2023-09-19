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

struct PetChangeView: View {

    @Binding var pet: Pet?
    @Environment(\.modelContext) var modelContext
    @State private var selectedImageData: Data?
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = Color.accent
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
                                Image(.defaultAnimal)
                                    .frame(width: 200, height: 200)
                            }
                            if !viewModel.defaultPhotoOn {
                                PhotoImagePickerView(photoData: $viewModel.outputImageData)
                                    .padding(.vertical)
                            }
                        }
                        Toggle("default_photo_label", isOn: $viewModel.defaultPhotoOn)
                            .tint(Color.accent)
                            .onChange(of: viewModel.defaultPhotoOn, {
                                if viewModel.defaultPhotoOn {
                                    viewModel.outputImageData = nil
                                }
                            })
                            .padding()
                        Text("photo_upload_detail_title")
                            .font(.footnote)
                            .foregroundColor(Color(.systemGray2))
                            .multilineTextAlignment(.center)
                            .padding()
                        Form {
                            Section {
                                TextField("tap_to_change_text", text: $viewModel.nameText)
                                DatePicker("birthday_title", selection: $viewModel.birthday, displayedComponents: .date)
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
                                await viewModel.savePet(pet: pet)
                            }
                            dismiss()
                        } label: {
                            Text("Save")
                                .bold()
                        }
                        .tint(tintColor)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
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
                Text("feed_selection_both")
                    .tag(FeedTimeSelection.both)
                Text("feed_selection_morning")
                    .tag(FeedTimeSelection.morning)
                Text("feed_selection_evening")
                    .tag(FeedTimeSelection.evening)
            } label: {
                Text("feed_time_title")
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
            "feed_selection_evening",
            selection: $viewModel.eveningDate,
            displayedComponents: .hourAndMinute
        )
    }

    var morningView: some View {
        DatePicker(
            "feed_selection_morning",
            selection: $viewModel.morningDate,
            displayedComponents: .hourAndMinute
        )
    }

}

#Preview {
    PetChangeView(pet: .constant(Pet()))
        .modelContainer(for: Pet.self)
}
