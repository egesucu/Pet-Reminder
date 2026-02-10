//
//  Pet​Image​Preview​View.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct Pet​Image​Preview​View: View {

    var selectedImage: UIImage
    var onDelete: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .glassEffect(.identity)

            Button(role: .destructive, action: onDelete) {
                Text("Remove")
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

    Pet​Image​Preview​View(selectedImage: image) {
        print("Image has been deleted.")
    }
        .padding()
}
#endif
