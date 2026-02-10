//
//  PetShowImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

struct PetShowImageView: View {

    var selectedImage: UIImage
    var onImageDelete: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .clipShape(.circle)

            Button(role: .destructive, action: onImageDelete) {
                Label("Remove", systemSymbol: .minusCircleFill)
            }
            .buttonStyle(.glass)
            .tint(.red)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var image = UIImage(resource: .defaultOther)

    PetShowImageView(selectedImage: image, onImageDelete: {
        print("Image has been deleted.")
    })
        .padding()
}
#endif
