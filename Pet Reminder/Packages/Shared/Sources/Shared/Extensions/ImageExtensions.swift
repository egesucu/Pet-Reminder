//
//  Image+Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import UIKit

extension UIImage {
    public static func loadImage(name: String) -> UIImage {
        UIImage(named: name) ?? UIImage()
    }
}
