//
//  Image+Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import UIKit
import SwiftUI

public extension UIImage {
    static func loadImage(name: String) -> UIImage {
        UIImage(named: name) ?? UIImage()
    }
}

public extension Image {
    func petImageStyle() -> some View {
        Group {
            self
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .clipShape(.circle)
                .contentShape(.circle)
        }
    }
}

public extension ImageResource {
    static func generateDefaultData(kind: Kind) -> Self {
        switch kind {
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
