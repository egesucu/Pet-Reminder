//
//  ESImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct ESImageView: View {
    
    var data: Data?
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View {
        if let data = data,
        let image = UIImage(data: data){
            ZStack {
                Rectangle()
                    .fill(tintColor)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(5)
            }
        } else {
            ZStack {
                Rectangle()
                    .fill(tintColor)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    
                Image("default-animal")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
    }
}

struct ESImageView_Previews: PreviewProvider {
    static var previews: some View {
        ESImageView()
    }
}
