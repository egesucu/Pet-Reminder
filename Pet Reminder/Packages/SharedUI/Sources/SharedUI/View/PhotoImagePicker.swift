//
//  PhotoImagePicker.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Shared
import SwiftUI
import PhotosUI

public struct PhotoImagePicker: View {
    @State private var isImporting = false
    @State private var showImportError = false
    @State private var selectedPhoto: PhotosPickerItem?
    var desiredTitle: LocalizedStringResource
    var desiredIcon: String
    @Binding var photoData: Data?

    public init(
        desiredTitle: LocalizedStringResource,
        selectedPhoto: PhotosPickerItem? = nil,
        photoData: Binding<Data?> = .constant(nil),
        desiredIcon: String = "photo.badge.plus.fill"
    ) {
        self.selectedPhoto = selectedPhoto
        self._photoData = photoData
        self.desiredTitle = desiredTitle
        self.desiredIcon = desiredIcon
    }

    public var body: some View {

        PhotosPicker(
            selection: $selectedPhoto,
            matching: .images
        ) {
            Label {
                Text(desiredTitle)
            } icon: {
                Image(systemName: desiredIcon)
            }
        }

        .task(id: selectedPhoto) {
            if let selectedPhoto {
                await handlePhotoChange(selectedPhoto)
            }
        }
        .overlay {
            if isImporting { ProgressView().allowsHitTesting(false) }
        }
        .disabled(isImporting)
        .alert(SharedStrings.resource("Could not load photo"), isPresented: $showImportError) { } message: {
            Text(SharedStrings.resource("This photo could not be processed. Please try another image."))
        }
        .contentShape(.rect)
        .tint(.accent)
        .padding(.vertical)
    }

    private func handlePhotoChange(_ newPhoto: PhotosPickerItem) async {
        await processPhotoChange(newPhoto)
    }

    private func processPhotoChange(_ newPhoto: PhotosPickerItem) async {
        isImporting = true
        defer { if !Task.isCancelled { isImporting = false } }
        let data = try? await newPhoto.loadTransferable(type: Data.self)
        guard !Task.isCancelled else { return }
        let processed: Data?
        if let data { processed = await PetPhotoImport.prepare(data) } else { processed = nil }
        guard !Task.isCancelled else { return }
        if let processed {
            photoData = processed
        } else {
            showImportError = true
        }
    }

}

#if DEBUG
#Preview("Photo picker with default title") {
    @Previewable @State var photoData: Data?

    PhotoImagePicker(
        desiredTitle: SharedStrings.addText,
        photoData: $photoData
    )
    .task {
        photoData = UIImage(resource: .defaultOther).pngData()
    }
    .environment(\.locale, .init(identifier: "tr"))
}

#Preview("Photo Picker with custom title") {
    @Previewable @State var photoData: Data?

    PhotoImagePicker(
        desiredTitle: SharedStrings.change,
        photoData: $photoData,
        desiredIcon: "photo.fill"
    )
    .task {
        photoData = UIImage(resource: .defaultOther).pngData()
    }
    .environment(\.locale, .init(identifier: "tr"))
}
#endif
