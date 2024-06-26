//
//  ColorExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog

extension Color: RawRepresentable {

    public typealias RawValue = String

    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .green
            return
        }
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .green
            self = Color(uiColor: color)
        } catch let error {
            Logger
                .settings
                .error("\(error)")
            self = .green
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
            return data.base64EncodedString()
        } catch let error {
            Logger
                .settings
                .error("\(error)")
        }
        return ""
    }
}

extension Color {
    var isDarkColor: Bool {
        var red, green, blue, alpha: CGFloat
        (red, green, blue, alpha) = (0, 0, 0, 0)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return  lum < 0.50
    }

    /// Black on Light Mode, White on Dark Mode
    static let label = Color(.label)
}
