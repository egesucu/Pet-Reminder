//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetChangeView: View {

    @Binding var pet: Pet?
    @State private var selectedImageData: Data?

    @State private var viewModel = PetChangeViewModel()

    var body: some View {
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
                            pet?.image = nil
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
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button {
                                        viewModel.changeName(pet: pet)
                                    } label: {
                                        Text("done")
                                    }
                                }
                            }
                            .onSubmit {
                                viewModel.changeName(pet: pet)
                            }
                        DatePicker("birthday_title", selection: $viewModel.birthday, displayedComponents: .date)
                            .onChange(of: viewModel.birthday) {
                                viewModel.changeBirthday(pet: pet)
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
        .navigationTitle(pet?.wrappedName ?? "")
        .task {
            await viewModel.getPetData(pet: pet)
        }
        .onChange(of: pet) {
            viewModel.updateView(pet: pet)
        }
    }

    var pickerView: some View {
        VStack {
            Toggle(isOn: $viewModel.shouldChangeFeedSelection) {
                Text("feed_change_feedtime")
            }
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
            .disabled(!viewModel.shouldChangeFeedSelection)
        }
        .onChange(of: viewModel.selection) {
            if viewModel.shouldChangeFeedSelection {
                viewModel.changeNotification(pet: pet, for: viewModel.selection)
            }
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
        .disabled(!viewModel.shouldChangeFeedSelection)
        .onChange(of: viewModel.eveningDate, {
            if viewModel.shouldChangeFeedSelection {
                viewModel.changeNotification(pet: pet, for: .evening)
            }
        })
    }

    var morningView: some View {
        DatePicker(
            "feed_selection_morning",
            selection: $viewModel.morningDate,
            displayedComponents: .hourAndMinute
        )
        .disabled(!viewModel.shouldChangeFeedSelection)
        .onChange(of: viewModel.morningDate, {
            if viewModel.shouldChangeFeedSelection {
                viewModel.changeNotification(pet: pet, for: .morning)
            }
        })
    }
    
    
}

#Preview {
    let preview = PersistenceController.preview.container.viewContext
    return PetChangeView(pet: .constant(Pet(context: preview)))
        .environment(\.managedObjectContext, preview)
}
