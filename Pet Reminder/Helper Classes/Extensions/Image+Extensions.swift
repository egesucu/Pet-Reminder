//
//  Image+Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import UIKit
import SwiftUI

extension UIImage {
    static func loadImage(name: String) -> UIImage {
        return UIImage(named: name) ?? UIImage()
    }
}
