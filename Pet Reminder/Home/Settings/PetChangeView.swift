//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct PetChangeView: View {
    
    var pet: Pet
    let persistence = PersistenceController.shared
    let notificationManager = NotificationManager.shared
    
    @State private var nameText = ""
    @State private var petImage : Image? = nil
    @State private var birthday = Date()
    @State private var selection = 0
    @State private var morningDate = Date()
    @State private var eveningDate = Date()
    @State private var showImagePicker = false
    @State private var outputImage: UIImage?
    @State private var defaultPhotoOn = false
    @State private var imageData : Data?
    var body: some View {
        
        VStack {
            ESImageView(data: pet.image)
                .onTapGesture {
                    self.showImagePicker = defaultPhotoOn ? false : true
                }
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    self.loadImage()
                }, content: {
                    ImagePickerView(image: $outputImage)
                })
                .frame(minWidth: 50, idealWidth: 100, maxWidth: 150, minHeight: 50, idealHeight: 100, maxHeight: 150, alignment: .center)
            Toggle("default_photo_label", isOn: $defaultPhotoOn)
                .onChange(of: defaultPhotoOn, perform: { _isOn in
                    if _isOn{
                        pet.image = nil
                        persistence.save()
                    }
                })
                .padding()
            Text("photo_upload_detail_title")
                .font(.footnote)
                .foregroundColor(Color(.systemGray2))
                .multilineTextAlignment(.center)
                .padding()
            Form{
                Section{
                    TextField("tap_to_change_text", text: $nameText)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button("Done"){
                                    self.changeName()
                                }
                            }
                        }
                        .onSubmit({
                            self.changeName()
                        })
                    DatePicker("birthday_title", selection: $birthday, displayedComponents: .date)
                        .onChange(of: birthday) { _ in
                            self.changeBirthday()
                        }
                }
                Section{
                    Picker("feed_time_title", selection: $selection) {
                        Text("feed_selection_both").tag(0)
                        Text("feed_selection_morning").tag(1)
                        Text("feed_selection_evening").tag(2)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selection == 0{
                        DatePicker("feed_selection_morning", selection: $morningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: morningDate) { _ in
                                self.changeNotification(for: .morning)
                            }
                        DatePicker("feed_selection_evening", selection: $eveningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningDate) { _ in
                                self.changeNotification(for: .evening)
                            }
                    } else if selection == 1 {
                        DatePicker("feed_selection_morning", selection: $morningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: morningDate) { _ in
                                self.changeNotification(for: .morning)
                            }
                    } else if selection == 2{
                        DatePicker("feed_selection_evening", selection: $eveningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningDate) { _ in
                                self.changeNotification(for: .evening)
                            }
                    }
                }
                
            }
            .navigationTitle(pet.name ?? "")
        }
        .onAppear{
            getPetData()
        }
        
    }
    
    func loadImage(){
        
        if let outputImage = outputImage {
            petImage = Image(uiImage: outputImage)
            
            if let data = outputImage.jpegData(compressionQuality: 0.8){
                pet.image = data
                self.imageData = data
                persistence.save()
            }
            
            defaultPhotoOn = false
        } else {
            petImage = nil
            defaultPhotoOn = true
        }
    }
    
    func getPetData(){
        self.birthday = pet.birthday ?? Date()
        self.nameText = pet.name!
        let selection = pet.selection
        switch selection {
        case .both:
            self.selection = 0
        case .morning:
            self.selection = 1
        case .evening:
            self.selection = 2
        }
        if let morning = pet.morningTime{
            self.morningDate = morning
        }
        if let evening = pet.eveningTime{
            self.eveningDate = evening
        }
        
        if let _ = pet.image{
            defaultPhotoOn = false
        } else {
            defaultPhotoOn = true
        }
    }
    
    func changeName(){
        pet.name = nameText
        switch selection{
        case 0:
            changeNotification(for: .both)
        case 1:
            changeNotification(for: .morning)
        case 2:
            changeNotification(for: .evening)
        default:
            break
        }
        persistence.save()
    }
    
    func changeBirthday(){
        pet.birthday = birthday
        persistence.save()
    }
    
    func changeNotification(for selection: Selection){
        switch selection {
        case .both:
            notificationManager.removeNotification(of: pet, with: .morning)
            notificationManager.removeNotification(of: pet, with: .evening)
            notificationManager.createNotification(of: pet, with: .morning, date: morningDate)
            notificationManager.createNotification(of: pet, with: .evening, date: eveningDate)
        case .morning:
            notificationManager.removeNotification(of: pet, with: .morning)
            notificationManager.createNotification(of: pet, with: .morning, date: morningDate)
        case .evening:
            notificationManager.removeNotification(of: pet, with: .evening)
            notificationManager.createNotification(of: pet, with: .evening, date: eveningDate)
        }
        let (morningTime, eveningTime) = (pet.morningTime,pet.eveningTime)
        
        if morningTime != nil {
            pet.morningTime = morningDate
        }
        if eveningTime != nil {
            pet.eveningTime = eveningDate
        }
        persistence.save()
    }
}

struct PetChangeView_Previews: PreviewProvider {
    static var previews: some View {
        let pet = Pet(context: PersistenceController.preview.container.viewContext)
        NavigationView {
            PetChangeView(pet: pet)
        }
    }
}
