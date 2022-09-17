//
//  AddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import SwiftUI
import PhotosUI

enum DayTime : Hashable {
    case morning, evening, both
}

struct AddPetView : View {
    
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @AppStorage("petSaved") var petSaved : Bool?
    
    @State private var dayType : DayTime = .both
    @State private var name = ""
    @State private var birthday : Date = .now
    @State private var morningFeed : Date = Date().eightAM()
    @State private var eveningFeed : Date = Date().eightPM()
    @State private var selectedImageData: Data? = nil
    
    var petManager = PetManager.shared
    
    var body: some View{
        ScrollView {
            VStack{
                Text("Name of your friend")
                    .font(.title2).bold()
                TextField("Can", text: $name)
                    .font(.title3)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.center)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(5)
                    .shadow(radius: 8)
                    .padding(.bottom,50)
                Text("When was your friend born?")
                    .font(.title2).bold()
                DatePicker("Birthday", selection: $birthday,displayedComponents: .date)
                    .labelsHidden()
                
                Text("Tap on the image to Select a photo")
                    .font(.title2).bold()
                if let selectedImageData {
                    HStack{
                        Spacer()
                        ZStack(alignment: .topTrailing){
                            Image(uiImage: UIImage(data: selectedImageData) ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxHeight: 150)
                                .shadow(radius: 10)
                            Button {
                                self.selectedImageData = nil
                            } label: {
                                Image(systemName: "x.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .background(Color.black)
                                    .cornerRadius(100)
                                    .offset(x: 0, y: 0)
                            }
                        }
                        Spacer()
                    }
                } else {
                    if #available(iOS 16, *){
                        PhotoImagePickerView { data in
                            selectedImageData = data
                        }.padding([.top,.bottom])
                    } else {
                        ImagePickerView(imageData: $selectedImageData).padding([.top,.bottom])
                    }
                    
                }
                
                Text("feed_time_title")
                    .font(.title2).bold()
                    .padding([.top,.bottom])
                Picker(selection: $dayType, label: Text("feed_time_title")) {
                    Text("feed_selection_both")
                        .tag(DayTime.both)
                    Text("feed_selection_morning")
                        .tag(DayTime.morning)
                    Text("feed_selection_evening")
                        .tag(DayTime.evening)
                }
                .pickerStyle(SegmentedPickerStyle())
                .animation(.easeOut(duration: 0.2), value: dayType)
                
                NotificationType()
                    .animation(.easeOut(duration: 0.2), value: dayType)
                    .padding(.all)
                
                
            }
            .padding([.leading,.top,.trailing])
            
            HStack {
                
                Button("Cancel", role: .destructive) {
                    cancel()
                }
                .buttonStyle(.borderedProminent)
                .font(.largeTitle)
                .padding(.trailing, 50)
                Button("Save") {
                    savePet()
                }
                .font(.largeTitle)
                .buttonStyle(.borderedProminent)
                .tint(Color.green)
                .disabled(name.isEmpty)
                
            }.padding(.all)
        }
        .interactiveDismissDisabled(!name.isEmpty)
    }
    
    @ViewBuilder func NotificationType() -> some View {
        switch dayType {
        case .morning:
            MorningView
        case .evening:
            EveningView
        default:
            BothView
        }
    }
    
    var MorningView: some View {
        HStack {
            Image("morning")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_morning",
                       selection: $morningFeed,
                       in: ...eveningFeed.addingTimeInterval(60),
                       displayedComponents: .hourAndMinute)
            
        }
        .animation(.easeOut(duration: 0.2), value: dayType)
        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)))
        
    }
    
    var EveningView: some View{
        HStack{
            Image("evening")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_evening",
                       selection: $eveningFeed,
                       in: morningFeed.addingTimeInterval(60)...,
                       displayedComponents: .hourAndMinute)
        }
        .animation(.easeOut(duration: 0.2), value: dayType)
        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)))
    }
    
    var BothView: some View {
        VStack {
            MorningView
                .padding([.top,.bottom])
            EveningView
        }
        .animation(.easeOut(duration: 0.2), value: dayType)
        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)))
    }
    
    private func savePet(){
        petManager.name = name
        petManager.birthday = birthday
        if let selectedImageData{
            petManager.imageData = selectedImageData
        }
        switch dayType {
        case .morning:
            petManager.morningTime = morningFeed
            petManager.selection = .morning
        case .evening:
            petManager.eveningTime = eveningFeed
            petManager.selection = .evening
        case .both:
            petManager.morningTime = morningFeed
            petManager.eveningTime = eveningFeed
            petManager.selection = .both
        }
        
        petManager.savePet() {
            petSaved = true
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func cancel(){
        presentationMode.wrappedValue.dismiss()
    }
    
}

struct AddPetView_Preview: PreviewProvider{
    
    static var previews: some View{
        AddPetView()
    }
}
