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
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accent)

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
                    .font(.title3)
                }
                .tint(tintColor.color)
                .onChange(of: selectedPhoto) { _ , newPhoto in
                    Task {
                        if let newPhoto = newPhoto {
                            await handlePhotoChange(newPhoto)
                        }
                    }
                }
                .padding(.vertical)
        }
    }
    
    @MainActor
    private func handlePhotoChange(_ newPhoto: PhotosPickerItem) async {
        await MainActor.run {
            processPhotoChange(newPhoto)
        }
    }
    
    @MainActor
    private func processPhotoChange(_ newPhoto: PhotosPickerItem) {
        Task {
            if let data = try? await newPhoto.loadTransferable(type: Data.self) {
                photoData = data
            }
        }
    }

}

#Preview {
    PhotoImagePickerView(photoData: .constant(nil))
}
