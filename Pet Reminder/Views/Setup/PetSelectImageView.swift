//
//  PetSelectImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import PhotosUI

struct PetSelectImageView: View {
    
    @Binding var selectedImageData: Data?
    
    var body: some View {
        if #available(iOS 16, *){
            PhotoImagePickerView { data in
                selectedImageData = data
            }.padding([.top,.bottom])
        } else {
            ImagePickerView(imageData: $selectedImageData).padding([.top,.bottom])
        }
    }
}

struct PetSelectImageView_Previews: PreviewProvider {
    static var previews: some View {
        PetSelectImageView(selectedImageData: .constant(nil))
    }
}
