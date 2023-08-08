//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetChangeView: View {

    var pet: Pet
    
    @State private var viewModel = PetChangeViewModel()

    var body: some View {
        VStack {
            ESImageView(data: viewModel.outputImageData)
                .onTapGesture {
                    viewModel.showImagePicker = viewModel.defaultPhotoOn ? false : true
                }
                .sheet(isPresented: $viewModel.showImagePicker, onDismiss: {
                    viewModel.loadImage(pet: pet)
                }, content: {
                    ImagePickerView(imageData: $viewModel.outputImageData)
                })
                .frame(
                    minWidth: 50,
                    idealWidth: 100,
                    maxWidth: 150,
                    minHeight: 50,
                    idealHeight: 100,
                    maxHeight: 150,
                    alignment: .center
                )
            Toggle("default_photo_label", isOn: $viewModel.defaultPhotoOn)
                .onChange(of: viewModel.defaultPhotoOn, {
                    if viewModel.defaultPhotoOn {
                        pet.image = nil
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
            .navigationTitle(pet.name ?? "")
        }
        .onAppear {
            viewModel.getPetData(pet: pet)
        }
    }

    var pickerView: some View {
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
        .onChange(of: viewModel.eveningDate, {
            viewModel.changeNotification(pet: pet, for: .evening)
        })
    }

    var morningView: some View {
        DatePicker(
            "feed_selection_morning",
            selection: $viewModel.morningDate,
            displayedComponents: .hourAndMinute
        )
        .onChange(of: viewModel.morningDate, {
            viewModel.changeNotification(pet: pet, for: .morning)
        })
    }
}

#Preview {
    PetChangeView(pet: .init())
}
