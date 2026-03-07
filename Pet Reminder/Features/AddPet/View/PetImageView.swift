//
//  PetImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PetImageView: View {

    @Binding var addPet: AddPet

    var body: some View {
        VStack {
            if let data = addPet.selectedImageData,
               let selectedImage = UIImage(data: data) {
                Pet​Image​Preview​View(selectedImage: selectedImage, onDelete: removeImage)
            } else {
                addPet
                    .type
                    .image
                    .frame(width: PRComponentSize.avatar200, height: PRComponentSize.avatar200)
                    .clipShape(.rect(cornerRadius: PRRadius.radius10))
            }

            PhotoImagePickerView(
                desiredTitle: .add,
                photoData: $addPet.selectedImageData
            )
                .padding(.vertical)
            Text(.photoUploadDetailTitle)
                .foregroundStyle(Color.label)
                .font(.footnote)
        }
    }

    func removeImage() {
        addPet.selectedImageData = nil
    }
}

#if DEBUG
#Preview {
    @Previewable @State var addPet: AddPet = .init()
    PetImageView(addPet: $addPet)
}
#endif
