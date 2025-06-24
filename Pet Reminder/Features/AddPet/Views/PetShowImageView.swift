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
        VStack {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxHeight: 180)
                .shadow(radius: 10)
                .padding(.trailing, 10)
            Button {
                onImageDelete()
            } label: {
                Text("Remove")
                    .font(.title3)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
    }
}

#Preview {
    let image = UIImage(resource: .defaultOther)
    PetShowImageView(selectedImage: image) {

    }
}
