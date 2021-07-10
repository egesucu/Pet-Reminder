//
//  SetupNameView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupNameView: View {
    
    @State private var name = ""
    @State private var birthday = Date()
    @State private var showImagePicker = false
    @State private var petImage : Image? = nil
    @State private var outputImage: UIImage?
    
    
    @StateObject var petManager = PetManager()
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading){
                Text("Name")
                    .font(.title).bold()
                TextField("Text", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 8)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom])
                Spacer()
                Text("Birthday")
                    .font(.title).bold()
                    .padding([.top,.bottom])
                DatePicker("Select the Date", selection: $birthday, displayedComponents: .date)
                    .padding([.top,.bottom])
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Set a Photo")
                    .font(.title).bold()
                    .padding([.top,.bottom])
                HStack {
                    Spacer()
                    ImageView()
                        .onTapGesture {
                            self.showImagePicker = true
                        }
                        .sheet(isPresented: $showImagePicker, onDismiss: {
                            self.loadImage()
                        }, content: {
                            ImagePicker(image: $outputImage)
                        })
                    Spacer()
                }
                
            }
            .padding()
            
            .navigationBarTitle("Basics", displayMode: .inline)
            .navigationBarItems(trailing: NextButton())
        }
        .navigationViewStyle(.stack)
        
    }
    
    func NextButton() -> some View {
        NavigationLink("Continue") {
            NotificationView(petManager: petManager)
        }
        .foregroundColor(name.isEmpty ? .gray : .green)
        .font(.body.bold())
        .disabled(name.isEmpty)
        .onTapGesture {
            self.petManager.saveImage(image: outputImage)
            self.petManager.saveNameAndBirthday(name: name, birthday: birthday)
        }
    }
    
    
    
    @ViewBuilder
    func ImageView() -> some View {
        
        if let petImage = petImage {
            petImage
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        } else {
            Image("default-animal")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
        
        
    }
    
    func loadImage(){
        
        if let outputImage = outputImage {
            petImage = Image(uiImage: outputImage)
        } else {
            petImage = nil
        }
    }
    
}

struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNameView(petManager: PetManager())
    }
}
