//
//  SetupPhotoView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupPhotoView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    @State private var petImage : Image? = nil
    @State private var selection : Int? = 0
    @State private var showingAlert = false
    @State var showImagePicker: Bool = false
    @State var inputImage: UIImage?
    @State private var useDefaultImage = false
    
    @StateObject var demoPet : DemoPet
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Upload")
                .font(.title)
                .multilineTextAlignment(.center)
            Spacer()
            if (petImage != nil){
                petImage?.resizable().scaledToFit().frame(width: 200, height: 200, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10))

            } else {
                Image("default-animal")
                    .resizable()
                    .frame(maxWidth: 150,maxHeight: 150)
                    .onTapGesture {
                    self.showImagePicker = true
                }.sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }
                .disabled(useDefaultImage)
            }
            Text("Tap the animal image to select a photo from your library")
                .font(.footnote)
                .font(.body).multilineTextAlignment(.center)
            Spacer()
            Toggle("I don't want to upload any photo", isOn: $useDefaultImage)
            Text("If you don't consent to upload your data, we'll use the default image. You can change it later.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Spacer()
            NavigationLink(
                destination: SelectNotificationView(demoPet: demoPet).environment(\.managedObjectContext, viewContext),
                tag: 1,
                selection: $selection,
                label: {EmptyView()})
            Button(action: {
                demoPet.saveImage(image: inputImage)
                self.selection = 1
            }, label: {
                Text("Next")
            })
            .buttonStyle(NextButton(conditionMet: !useDefaultImage && petImage == nil))
            .disabled(!useDefaultImage && petImage == nil)
               
            .navigationBarTitle("Photo",displayMode: .inline)
        }.padding()
    }
    
    private func loadImage(){
        
        if let image = inputImage {
            petImage = Image(uiImage: image)
        } else {
            return
        }
    }
    
}

struct SetupPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            SetupPhotoView(demoPet: DemoPet())
        }
    }
}
