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
    @State private var petImageToSave : UIImage? = nil
    
    
    
    @StateObject var demoPet : DemoPet
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Upload").font(.largeTitle).multilineTextAlignment(.center)
            Spacer()
            Text("Tap the animal image to select a photo from your library")
                .font(.body).multilineTextAlignment(.center)
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
            Spacer()
            Toggle("I don't want to upload any photo", isOn: $useDefaultImage)
            Text("If you don't consent to upload your data, we'll use the default image.")
                .font(.footnote).multilineTextAlignment(.center).foregroundColor(.gray)
            
            Spacer()
            NavigationLink(
                destination: SelectNotificationView(demoPet: demoPet).environment(\.managedObjectContext, viewContext),
                tag: 1,
                selection: $selection,
                label: {
                    Button(action: {
                        self.selection = 1
                    }, label: {
                    Text("Next")
                        .font(Font.system(size: 35))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity,idealHeight: 60)
                        .padding([.leading, .trailing], 20)
                        .background(Color.green)
                        .cornerRadius(UIScreen.main.bounds.width / 2)
                        .shadow(color: Color.black.opacity(0.6),radius: 4, x:0, y:2)
                })
                
                })
            .navigationBarTitle("Photo",displayMode: .inline)

        }.padding()
        
        
    }
    
    private func loadImage(){
        guard let inputImage = inputImage else {return}
        
        demoPet.petImage = inputImage
        petImage = Image(uiImage: inputImage)
        petImageToSave = inputImage
    }
    
}

struct SetupPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            SetupPhotoView(demoPet: DemoPet())
        }
    }
}
