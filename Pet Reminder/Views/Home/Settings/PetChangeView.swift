//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetChangeView: View {

    var pet: Pet
    let notificationManager = NotificationManager.shared

    @State private var nameText = ""
    @State private var petImage: Image?
    @State private var birthday = Date()
    @State private var selection = 0
    @State private var morningDate = Date.now.eightAM()
    @State private var eveningDate = Date.now.eightPM()
    @State private var showImagePicker = false
    @State private var outputImageData: Data?
    @State private var defaultPhotoOn = false
    var body: some View {

        VStack {
            ESImageView(data: outputImageData)
                .onTapGesture {
                    self.showImagePicker = defaultPhotoOn ? false : true
                }
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    self.loadImage()
                }, content: {
                    ImagePickerView(imageData: $outputImageData)
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
            Toggle("default_photo_label", isOn: $defaultPhotoOn)
                .onChange(of: defaultPhotoOn, {
                    if defaultPhotoOn {
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
                    TextField("tap_to_change_text", text: $nameText)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button("done") {
                                    self.changeName()
                                }
                            }
                        }
                        .onSubmit({
                            self.changeName()
                        })
                    DatePicker("birthday_title", selection: $birthday, displayedComponents: .date)
                        .onChange(of: birthday) {
                            self.changeBirthday()
                        }
                }
                Section {
                    Picker("feed_time_title", selection: $selection) {
                        Text("feed_selection_both").tag(0)
                        Text("feed_selection_morning").tag(1)
                        Text("feed_selection_evening").tag(2)

                    }
                    .pickerStyle(.segmented)

                    if selection == 0 {
                        DatePicker(
                            "feed_selection_morning",
                            selection: $morningDate,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: morningDate) {
                            self.changeNotification(for: .morning)
                        }
                        DatePicker(
                            "feed_selection_evening",
                            selection: $eveningDate,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: eveningDate) {
                            self.changeNotification(for: .evening)
                        }
                    } else if selection == 1 {
                        DatePicker(
                            "feed_selection_morning",
                            selection: $morningDate,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: morningDate, {
                            self.changeNotification(for: .morning)
                        })
                    } else if selection == 2 {
                        DatePicker(
                            "feed_selection_evening",
                            selection: $eveningDate,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: eveningDate, {
                            self.changeNotification(for: .evening)
                        })
                    }
                }

            }
            .navigationTitle(pet.name)
        }
        .onAppear {
            getPetData()
        }

    }

    func loadImage() {
        if let outputImageData {
            petImage = Image(uiImage: UIImage(data: outputImageData) ?? UIImage())
            pet.image = outputImageData
            defaultPhotoOn = false
        } else {
            outputImageData = nil
            defaultPhotoOn = true
        }
    }

    func getPetData() {
        self.birthday = pet.birthday ?? Date()
        self.nameText = pet.name
        let selection = pet.selection
        switch selection {
        case .both:
            self.selection = 0
        case .morning:
            self.selection = 1
        case .evening:
            self.selection = 2
        }
        if let morning = pet.morningTime {
            self.morningDate = morning
        }
        if let evening = pet.eveningTime {
            self.eveningDate = evening
        }

        if let image = pet.image {
            outputImageData = image
            defaultPhotoOn = false
        } else {
            defaultPhotoOn = true
        }
    }

    func changeName() {
        pet.name = nameText
        switch selection {
        case 0:
            changeNotification(for: .both)
        case 1:
            changeNotification(for: .morning)
        case 2:
            changeNotification(for: .evening)
        default:
            break
        }
    }

    func changeBirthday() {
        pet.birthday = birthday
    }

    func changeNotification(for selection: FeedTimeSelection) {
        switch selection {
        case .both:
            notificationManager.removeNotification(of: pet.name, with: .morning)
            notificationManager.removeNotification(of: pet.name, with: .evening)
            notificationManager.createNotification(of: pet.name, with: .morning, date: morningDate)
            notificationManager.createNotification(of: pet.name, with: .evening, date: eveningDate)
        case .morning:
            notificationManager.removeNotification(of: pet.name, with: .morning)
            notificationManager.createNotification(of: pet.name, with: .morning, date: morningDate)
        case .evening:
            notificationManager.removeNotification(of: pet.name, with: .evening)
            notificationManager.createNotification(of: pet.name, with: .evening, date: eveningDate)
        }
        let (morningTime, eveningTime) = (pet.morningTime, pet.eveningTime)

        if morningTime != nil {
            pet.morningTime = morningDate
        }
        if eveningTime != nil {
            pet.eveningTime = eveningDate
        }
    }
}

// #Preview {
//    MainActor.assumeIsolated {
//        PetChangeView(pet: PreviewSampleData.previewPet)
//            .modelContainer(PreviewSampleData.container)
//    }
//    
// }

struct PetChangeDemo: PreviewProvider {
    static var previews: some View {
        PetChangeView(pet: PreviewSampleData.previewPet)
            .modelContainer(for: Pet.self)
    }
}
