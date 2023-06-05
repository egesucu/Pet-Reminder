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
    let persistence = PersistenceController.shared
    let notificationManager = NotificationManager.shared
    
    @State private var nameText = ""
    @State private var petImage : Image? = nil
    @State private var birthday = Date()
    @State private var selection = 0
    @State private var morningDate = Date.now.eightAM()
    @State private var eveningDate = Date.now.eightPM()
    @State private var showImagePicker = false
    @State private var outputImageData: Data? = nil
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
                .frame(minWidth: 50, idealWidth: 100, maxWidth: 150, minHeight: 50, idealHeight: 100, maxHeight: 150, alignment: .center)
            Toggle(Strings.defaultPhotoLabel, isOn: $defaultPhotoOn)
                .onChange(of: defaultPhotoOn, perform: { _isOn in
                    if _isOn{
                        pet.image = nil
                        persistence.save()
                    }
                })
                .padding()
            Text(Strings.photoUploadDetailTitle)
                .font(.footnote)
                .foregroundColor(Color(.systemGray2))
                .multilineTextAlignment(.center)
                .padding()
            Form{
                Section{
                    TextField(Strings.tapToChangeText, text: $nameText)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button(Strings.done){
                                    self.changeName()
                                }
                            }
                        }
                        .onSubmit({
                            self.changeName()
                        })
                    DatePicker(Strings.birthdayTitle, selection: $birthday, displayedComponents: .date)
                        .onChange(of: birthday) { _ in
                            self.changeBirthday()
                        }
                }
                Section{
                    Picker(Strings.feedTimeTitle, selection: $selection) {
                        Text(Strings.feedSelectionBoth).tag(0)
                        Text(Strings.feedSelectionMorning).tag(1)
                        Text(Strings.feedSelectionEvening).tag(2)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selection == 0{
                        DatePicker(Strings.feedSelectionMorning, selection: $morningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: morningDate) { _ in
                                self.changeNotification(for: .morning)
                            }
                        DatePicker(Strings.feedSelectionEvening, selection: $eveningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: eveningDate) { _ in
                                self.changeNotification(for: .evening)
                            }
                    } else if selection == 1 {
                        DatePicker(Strings.feedSelectionMorning, selection: $morningDate, displayedComponents: .hourAndMinute)
                            .onChange(of: morningDate) { _ in
                                self.changeNotification(for: .morning)
                            }
                    } else if selection == 2{
                        DatePicker(Strings.feedSelectionEvening, selection: $eveningDate, displayedComponents: .hourAndMinute)
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
        if let outputImageData{
            petImage = Image(uiImage: UIImage(data: outputImageData) ?? UIImage())
            pet.image = outputImageData
            persistence.save()
            defaultPhotoOn = false
        } else {
            outputImageData = nil
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
        
        if let image = pet.image{
            outputImageData = image
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
    
    func changeNotification(for selection: NotificationSelection){
        switch selection {
        case .both:
            notificationManager.removeNotification(of: pet.name ?? "", with: .morning)
            notificationManager.removeNotification(of: pet.name ?? "", with: .evening)
            notificationManager.createNotification(of: pet.name ?? "", with: .morning, date: morningDate)
            notificationManager.createNotification(of: pet.name ?? "", with: .evening, date: eveningDate)
        case .morning:
            notificationManager.removeNotification(of: pet.name ?? "", with: .morning)
            notificationManager.createNotification(of: pet.name ?? "", with: .morning, date: morningDate)
        case .evening:
            notificationManager.removeNotification(of: pet.name ?? "", with: .evening)
            notificationManager.createNotification(of: pet.name ?? "", with: .evening, date: eveningDate)
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