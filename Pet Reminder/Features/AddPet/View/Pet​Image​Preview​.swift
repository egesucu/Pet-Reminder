//
//  Pet​Image​Preview​.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct Pet​Image​Preview​: View {

    var selectedImage: UIImage
    var onDelete: @MainActor () -> Void

    var body: some View {
        VStack(spacing: .spacing16) {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: .radius10))
                .glassEffect(.identity)

            Button(role: .destructive, action: onDelete) {
                Text(.remove)
                    .font(.title2)
                    .padding()
            }
            .buttonStyle(.glass)
            .tint(.red)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var image = UIImage(resource: .defaultOther)

    Pet​Image​Preview​(selectedImage: image) {
        print("Image has been deleted.")
    }
        .padding()
}
#endif
