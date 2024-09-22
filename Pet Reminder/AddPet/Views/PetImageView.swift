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
    @Binding var petType: PetType

    var body: some View {
        VStack {
            if let selectedImageData,
            let selectedImage = UIImage(data: selectedImageData) {
                PetShowImageView(selectedImage: selectedImage, onImageDelete: removeImage)
            } else {
                petType
                    .image
                    .frame(width: 200, height: 200)
                    .clipShape(.rect(cornerRadius: 10))
            }

            PhotoImagePickerView(photoData: $selectedImageData)
                .padding(.vertical)
            Text("photo_upload_detail_title")
                .font(.footnote)
        }
    }

    func removeImage() {
        selectedImageData = nil
    }
}

#Preview {
    @Previewable @State var selectedImageData: Data?
    PetImageView(
        selectedImageData: $selectedImageData,
        petType: .constant(.dog)
    )
}
