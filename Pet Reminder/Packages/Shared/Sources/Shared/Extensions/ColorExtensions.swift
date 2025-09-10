//
//  ColorExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

public extension Color {
    var isDarkColor: Bool {

        let cgColor = self.resolve(in: .init()).cgColor

        guard let components = cgColor.components else {
            return false
        }

        let red, green, blue: CGFloat

        switch components.count {
        case 2: // Grayscale + alpha
            red = components[0]
            green = components[0]
            blue = components[0]
        case 4: // RGBA
            red = components[0]
            green = components[1]
            blue = components[2]
        default:
            return false
        }

        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance < 0.5
    }

    /// Black on Light Mode, White on Dark Mode
    static let label = Color(.label)
    /// White-ish on Light Mode, Black on Dark Mode
    static let background = Color(uiColor: .systemBackground)
}

#if DEBUG

#Preview {
    VStack {
        Color.label
            .clipShape(.circle)
        Spacer()
        Color.background
            .clipShape(.circle)
    }
    .background(Color.accent)
    .padding()
}

#endif
