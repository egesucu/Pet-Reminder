//
//  PetImageSelection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PetImageSelection: View {

    @Binding var model: AddPet.Model

    var body: some View {
        VStack {
            if let data = model.selectedImageData,
               let selectedImage = UIImage(data: data) {
                Pet​Image​Preview​(selectedImage: selectedImage, onDelete: removeImage)
            } else {
                model
                    .kind
                    .image
                    .frame(width: .avatar200, height: .avatar200)
                    .clipShape(.rect(cornerRadius: .radius10))
            }

            PhotoImagePicker(
                desiredTitle: .add,
                photoData: $model.selectedImageData
            )
                .padding(.vertical)
            Text(.photoUploadDetailTitle)
                .foregroundStyle(Color.label)
                .font(.footnote)
        }
    }

    func removeImage() {
        model.selectedImageData = nil
    }
}

#if DEBUG
#Preview {
    @Previewable @State var model: AddPet.Model = .init()
    PetImageSelection(model: $model)
}
#endif
