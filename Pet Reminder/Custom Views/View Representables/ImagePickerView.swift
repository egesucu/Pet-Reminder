//
//  ImagePickerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var imageData: Data?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }


    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
               if let uiImage = info[.editedImage] as? UIImage {
                   parent.imageData = uiImage.jpegData(compressionQuality: 0.8)
               }

               parent.presentationMode.wrappedValue.dismiss()
           }
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {

    }
    
   
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

