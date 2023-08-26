//
//  PetShowImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetShowImageView: View {

    var selectedImage: UIImage
    var onImageDelete: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxHeight: 150)
                .shadow(radius: 10)
                .padding(.trailing, 10)
            Button {
                onImageDelete()
            } label: {
                Text("Remove")
                    .font(.title)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            Spacer()
        }
    }
}

#Preview {
    let image = UIImage(resource: .defaultAnimal)
    return PetShowImageView(selectedImage: image) {

    }
}
