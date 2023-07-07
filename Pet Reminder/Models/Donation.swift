//
//  Donation.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Donation {
    var productID: String?
    var purchasedAt: Date?

    init(productID: String? = nil,
         purchasedAt: Date? = nil) {
        self.productID = productID
        self.purchasedAt = purchasedAt
    }
}
