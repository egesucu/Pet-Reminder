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
    
    var body: some View {
        if let data = data,
        let image = UIImage(data: data){
            ZStack {
                Rectangle()
                    .fill(Color(.systemGreen))
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .frame(width: 250, height: 250, alignment: .center)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
                    .clipShape(Circle())
            }
        } else {
            ZStack {
                Rectangle()
                    .fill(Color(.systemGreen))
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .frame(width: 250, height: 250, alignment: .center)
                Image("default-animal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: .center)
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
