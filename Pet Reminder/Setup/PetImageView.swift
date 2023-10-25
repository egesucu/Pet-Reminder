//
//  PetImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog

struct PetImageView: View {

    @Binding var selectedImageData: Data?
    @Binding var selectedPage: SetupSteps

    var body: some View {
        VStack {
            if let selectedImageData,
            let selectedImage = UIImage(data: selectedImageData) {
                PetShowImageView(selectedImage: selectedImage, onImageDelete: removeImage)
            } else {
                Image(.defaultAnimal)
                    .frame(width: 200, height: 200)
            }

            PhotoImagePickerView(photoData: $selectedImageData)
                .padding(.vertical)
            Text("photo_upload_detail_title")
                .font(.footnote)
        }
        .onChange(of: selectedImageData) { _, _ in
            Logger
                .pets
                .info("Selected Page is: \(selectedPage.text)")
        }
    }

    func removeImage() {
        selectedImageData = nil
    }
}

#Preview {
    PetImageView(selectedImageData: .constant(nil), selectedPage: .constant(.birthday))
}
