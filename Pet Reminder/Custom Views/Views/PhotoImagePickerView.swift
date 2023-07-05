//
//  PhotoImagePickerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import PhotosUI

@available (iOS 16.0, *)
struct PhotoImagePickerView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var onSelected: (Data) -> Void

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedPhoto,
                         matching: .images) {
                Image(.defaultAnimal)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .cornerRadius(50)
                    .padding()
                    .background(tintColor)
                    .cornerRadius(50)
                    .shadow(radius: 10)
            }
            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        onSelected(data)
                    }
                }
            }
            .padding(.vertical)
        }
    }

}
