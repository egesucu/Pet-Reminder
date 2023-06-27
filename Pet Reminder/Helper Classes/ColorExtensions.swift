//
//  ColorExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
// swiftlint: disable todo
// FIXME: Check color extension issues on a newer Xcode version.
// swiftlint: enable todo
// extension Color: RawRepresentable {
//    
//    public typealias RawValue = String
//    
//    public var rawValue: String {
//        
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor.self, requiringSecureCoding: true)
//            return data.base64EncodedString()
//        } catch let error {
//            print(error)
//            return ""
//        }
//    }
//    
//    public init?(rawValue: String) {
//        guard let data = Data(base64Encoded: rawValue) else {
//            self = .black
//            return
//        }
//        do {
//            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
//            if let color = color {
//                self = Color(uiColor: color)
//            }
//        } catch let error {
//            print(error)
//            self = .black
//        }
//    }
// }

// MARK: UIColor Extension
extension UIColor {
    var isDarkColor: Bool {
        var red, green, blue, alpha: CGFloat
        (red, green, blue, alpha) = (0, 0, 0, 0)
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return  lum < 0.50
    }
}

extension Color {
    var isDarkColor: Bool {
        UIColor(self).isDarkColor
    }
    static let dynamicBlack = Color(.label)
    static let systemGreen = Color(.systemGreen)

    static var tintColor: Color {
        .accentColor
    }
}
