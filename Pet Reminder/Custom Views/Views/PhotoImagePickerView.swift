//
//  PhotoImagePickerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import PhotosUI

struct PhotoImagePickerView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    @Binding var photoData: Data?

    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images) {
                    Label(
                        "Select a photo",
                        systemImage: "photo.fill"
                    )
                    .font(.title)
                }
                .tint(tintColor)
                .onChange(of: selectedPhoto) {
                    Task {
                        if let data = try? await selectedPhoto?
                            .loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }
                .padding(.vertical)
        }
    }

}

#Preview {
    PhotoImagePickerView(photoData: .constant(nil))
}
