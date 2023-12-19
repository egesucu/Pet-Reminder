//
//  ImagePickerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: Lifecycle

    init(_ parent: ImagePickerView) {
      self.parent = parent
    }

    // MARK: Internal

    let parent: ImagePickerView

    func imagePickerController(
      _: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
      if let uiImage = info[.editedImage] as? UIImage {
        parent.imageData = uiImage.jpegData(
          compressionQuality: 0.8)
      }

      parent.presentationMode.wrappedValue.dismiss(
      )
    }
  }

  @Environment(\.presentationMode) var presentationMode
  @Binding var imageData: Data?

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<ImagePickerView>)
    -> UIImagePickerController
  {
    let picker = UIImagePickerController(
    )
    picker.delegate = context.coordinator
    picker.allowsEditing = true
    return picker
  }

  func updateUIViewController(
    _: UIImagePickerController,
    context _: UIViewControllerRepresentableContext<ImagePickerView>) { }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
