//
//  PetImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetImageView: View {
    
    @Binding var selectedImageData: Data?
    var onImageDelete: () -> ()
    
    var body: some View {
        VStack {
            Text("photo_set_label")
                .font(.title2).bold()
            if let selectedImageData,
            let selectedImage = UIImage(data: selectedImageData) {
                PetShowImageView(selectedImage: selectedImage, onImageDelete: onImageDelete)
            } else {
                PetSelectImageView(selectedImageData: $selectedImageData)
            }
            Text("photo_upload_detail_title")
                .font(.footnote)
        }
    }
}

struct PetImageView_Previews: PreviewProvider {
    static var previews: some View {
        PetImageView(selectedImageData: .constant(nil)) {
            
        }
    }
}
