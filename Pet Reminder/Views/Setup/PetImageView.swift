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

    var body: some View {
        VStack {
            if let selectedImageData,
            let selectedImage = UIImage(data: selectedImageData) {
                PetShowImageView(selectedImage: selectedImage, onImageDelete: removeImage)
            } else {
                PhotoImagePickerView(photoData: $selectedImageData)
                    .padding(.vertical)
            }
            Text("photo_upload_detail_title")
                .font(.footnote)
        }
    }

    func removeImage() {
        selectedImageData = nil
    }
}

#Preview {
    PetImageView(selectedImageData: .constant(nil))
}
