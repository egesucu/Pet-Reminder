//
//  PaymentErrorType.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum PaymentErrorType: String,Error{
    case cantPay = ""
    
    func localizedString() -> String {
        return Strings.paymentCant
    }
    
    static func getTitleFor(title:PaymentErrorType) -> String {
        return title.localizedString()
    }
}
