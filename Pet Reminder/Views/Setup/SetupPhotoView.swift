//
//  SetupPhotoView.swift
//  SetupPhotoView
//
//  Created by egesucu on 30.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct SetupPhotoView: View {
    
    @State private var showImagePicker = false
    @State private var petImage : Image? = nil
    @State private var outputImage: UIImage?
    
    var petManager : PetManager
    
    var body: some View {
        VStack{
            Text("Set a Photo")
                .font(.title).bold()
                .padding([.top,.bottom])
            ImageView()
                .onTapGesture {
                    self.showImagePicker = true
                }
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    self.loadImage()
                }, content: {
                    ImagePicker(image: $outputImage)
                })
                .padding([.top,.bottom])
            
        }
        .onAppear(){
            
            if let outputImage = outputImage{
                petManager.getImage(image: outputImage)
            } else {
                petManager.getImage()
            }

        }
        .navigationTitle(Text("Photo"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                NavigationLink(
                    destination: SetupNotificationView(petManager: petManager),
                    label: {
                        Text("Continue")
                    })
                .font(.body.bold())
            }
        }
    }
    
    
    @ViewBuilder
    func ImageView() -> some View {
        
        if let petImage = petImage {
            petImage
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(50)
                .padding()
                .background(Color(.systemGreen))
                .cornerRadius(50)
                .shadow(radius: 10)
        } else {
            Image("default-animal")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(50)
                .padding()
                .background(Color(.systemGreen))
                .cornerRadius(50)
                .shadow(radius: 10)
            
        }
        
    }
    
    func loadImage(){
        
        if let outputImage = outputImage {
            petImage = Image(uiImage: outputImage)
            petManager.getImage(image: outputImage)
        } else {
            petImage = nil
            petManager.getImage()
        }
    }
    
    
}

struct SetupPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupPhotoView(petManager: PetManager())
        }
    }
}
