//
//  PetImageSelection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI

struct PetImageSelection: View {

    @Binding var model: AddPet.Model

    @State private var breedInput = String.empty

    var body: some View {
        VStack(alignment: .leading) {
            Text(SharedStrings.petKindText)
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(alignment: .center, spacing: .spacing12) {
                Picker(selection: $model.kind) {
                    ForEach(Kind.allCases, id: \.self) { kind in
                        Text(verbatim: kind.localizedName)
                    }
                } label: {
                    Text(SharedStrings.petKindText)
                }
                .pickerStyle(.segmented)

                TextField(SharedStrings.petBreedOptional, text: $breedInput)
                    .onChange(of: breedInput) {
                        model.updateBreed(from: breedInput)
                    }
                    .textFieldStyle(.outlined)

                petImage
                    .petPhotoDrop(data: $model.selectedImageData)

                PhotoImagePicker(
                    desiredTitle: SharedStrings.add,
                    photoData: $model.selectedImageData
                )
            }

            Text(SharedStrings.photoUploadDetailTitle)
                .foregroundStyle(Color.label)
                .font(.footnote)
        }
    }

    func removeImage() {
        model.selectedImageData = nil
    }
}

// MARK: - Subviews
private extension PetImageSelection {
    @ContentBuilder var petImage: some View {
        if let data = model.selectedImageData,
           let selectedImage = UIImage(data: data) {
            preview(for: selectedImage)
        } else {
            model
                .kind
                .image
                .frame(width: .avatar200, height: .avatar200)
                .clipShape(.rect(cornerRadius: .radius10))
        }
    }

    func preview(for image: UIImage) -> some View {
        VStack(spacing: .spacing16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: .radius10))
                .glassEffect(.identity)

            Button(role: .destructive, action: removeImage) {
                Text(SharedStrings.resource("Delete Photo"))
            }
            .buttonStyle(.glass)
            .tint(.red)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var model: AddPet.Model = .init()

    PetImageSelection(model: $model)
        .padding(.horizontal)
}
#endif
