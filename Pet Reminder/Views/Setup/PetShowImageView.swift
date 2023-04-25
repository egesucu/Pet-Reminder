//
//  PetShowImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetShowImageView: View {
    
    var selectedImage: UIImage
    var onImageDelete: () -> ()
    
    var body: some View {
        HStack{
            Spacer()
            ZStack(alignment: .topTrailing){
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxHeight: 150)
                    .shadow(radius: 10)
                Button {
                    onImageDelete()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                        .background(Color.black)
                        .cornerRadius(100)
                        .offset(x: -10, y: 10)
                }
            }
            Spacer()
        }
    }
}

struct PetShowImageView_Previews: PreviewProvider {
    static var previews: some View {
        PetShowImageView(selectedImage: UIImage(named: "default-animal")!) {
            
        }
    }
}
