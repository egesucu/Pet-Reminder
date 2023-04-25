//
//  PaymentErrorType.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum PaymentErrorType: String,Error{
    case cantPay = "payment_cant"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    static func getTitleFor(title:PaymentErrorType) -> String {
        return title.localizedString()
    }
}
