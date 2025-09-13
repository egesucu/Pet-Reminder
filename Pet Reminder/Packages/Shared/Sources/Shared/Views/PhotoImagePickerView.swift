//
//  PhotoImagePickerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import PhotosUI
import SFSafeSymbols

public struct PhotoImagePickerView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    var desiredTitle: LocalizedStringResource
    var desiredIcon: SFSymbol
    @Binding var photoData: Data?

    public init(
        desiredTitle: LocalizedStringResource,
        selectedPhoto: PhotosPickerItem? = nil,
        photoData: Binding<Data?> = .constant(nil),
        desiredIcon: SFSymbol = .photoBadgePlusFill
    ) {
        self.selectedPhoto = selectedPhoto
        self._photoData = photoData
        self.desiredTitle = desiredTitle
        self.desiredIcon = desiredIcon
    }

    public var body: some View {

        PhotosPicker(
            selection: $selectedPhoto,
            matching: .any(
                of: [.images, .not(.screenshots), .not(.bursts)]
            )
        ) {
            Label {
                Text(desiredTitle)
            } icon: {
                Image(systemSymbol: desiredIcon)
            }
        }

        .onChange(of: selectedPhoto) {
            Task {
                if let selectedPhoto {
                    await handlePhotoChange(selectedPhoto)
                }
            }
        }
        .contentShape(.rect)
        .tint(.accent)
        .padding(.vertical)
    }

    private func handlePhotoChange(_ newPhoto: PhotosPickerItem) async {
        await processPhotoChange(newPhoto)
    }

    private func processPhotoChange(_ newPhoto: PhotosPickerItem) async {
        if let data = try? await newPhoto.loadTransferable(type: Data.self) {
            photoData = data
        } else {
            photoData = nil
            selectedPhoto = nil
        }
    }

}

#if DEBUG
#Preview("Photo picker with default title") {
    @Previewable @State var photoData: Data?

    PhotoImagePickerView(
        desiredTitle: .addText,
        photoData: $photoData
    )
    .task {
        photoData = UIImage(resource: .defaultOther).pngData()
    }
    .environment(\.locale, .init(identifier: "tr"))
}

#Preview("Photo Picker with custom title") {
    @Previewable @State var photoData: Data?

    PhotoImagePickerView(
        desiredTitle: .change,
        photoData: $photoData,
        desiredIcon: .photoFill
    )
    .task {
        photoData = UIImage(resource: .defaultOther).pngData()
    }
    .environment(\.locale, .init(identifier: "tr"))
}
#endif
