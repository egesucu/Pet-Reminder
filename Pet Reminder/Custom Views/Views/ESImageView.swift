//
//  ESImageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct ESImageView: View {

    var data: Data?
    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    var body: some View {
        if let data = data,
        let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(5)
        } else {
            ZStack {
                Rectangle()
                    .fill(tintColor)
                    .clipShape(.rect(cornerRadius: 25))
                    .shadow(radius: 10)

                Image(.defaultAnimal)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    ESImageView()
}
