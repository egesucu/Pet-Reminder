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
    var type: PetType

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
            Image(definePetType)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        }
    }
    
    private var definePetType: ImageResource {
        switch type {
        case .cat:
                .defaultCat
        case .dog:
                .defaultDog
        case .fish:
                .defaultFish
        case .bird:
                .defaultBird
        case .other:
                .defaultOther
        }
    }
}

#Preview {
    ESImageView(type: .cat)
}
