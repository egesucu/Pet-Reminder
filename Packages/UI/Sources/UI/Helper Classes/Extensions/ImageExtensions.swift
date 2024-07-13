//
//  Image+Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import UIKit
import SwiftUI
import SharedModels

extension UIImage {
    static func loadImage(name: String) -> UIImage {
        return UIImage(named: name) ?? UIImage()
    }
}
