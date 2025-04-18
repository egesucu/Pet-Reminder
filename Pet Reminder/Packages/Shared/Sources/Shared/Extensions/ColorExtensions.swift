//
//  ColorExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

extension Color {
    public var isDarkColor: Bool {
        var red, green, blue, alpha: CGFloat
        (red, green, blue, alpha) = (0, 0, 0, 0)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return  lum < 0.50
    }
    
    /// Black on Light Mode, White on Dark Mode
    public static let label = Color(.label)
}
