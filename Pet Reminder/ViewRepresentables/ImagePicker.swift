//
//  ImagePicker.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }


    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
               if let uiImage = info[.editedImage] as? UIImage {
                   parent.image = uiImage
               }

               parent.presentationMode.wrappedValue.dismiss()
           }
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
   
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

