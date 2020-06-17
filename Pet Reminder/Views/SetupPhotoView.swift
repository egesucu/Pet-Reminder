//
//  SetupPhotoView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupPhotoView: View {
    
    @EnvironmentObject var pet : PetModel
    @State private var petImage : Image? = nil
    
    @State private var tag:Int? = nil
    @State private var showingAlert = false
    @State var showImagePicker: Bool = false
    
    @State var inputImage: UIImage?
    
    
    
    
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Upload").font(.largeTitle)
            Spacer()
            if (petImage != nil){
                petImage?.resizable().scaledToFit().frame(width: 200, height: 200, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10))
                
            } else {
                Image(systemName: "plus").font(.system(size: 60)).onTapGesture {
                    self.showImagePicker = true
                }.sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }
            }
            
            Spacer()
            NavigationLink(destination: SelectNotificationView(), tag: 1, selection: $tag) {
                EmptyView()
            }.navigationBarTitle("Photo",displayMode: .inline)
            
            
            Button("Next") {
                if (self.petImage == nil){
                    self.showingAlert = true
                } else {
                    self.tag = 1
                }
            }.font(Font.system(size: 35)).foregroundColor(.white).frame(minWidth: 0, maxWidth: .infinity).frame(height: 60)
                .padding([.leading, .trailing], 20).background(Color.green).cornerRadius(UIScreen.main.bounds.width / 2).shadow(color: Color.black.opacity(0.6),radius: 4, x:0, y:2)
            
        }.padding()
        
        
    }
    
    private func loadImage(){
        guard let inputImage = inputImage else {return}
        petImage = Image(uiImage: inputImage)
        pet.imageData = inputImage.pngData()!
    }
    
    
   
    
    
    
    
}

struct SetupPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SetupPhotoView().environmentObject(PetModel())
    }
}
