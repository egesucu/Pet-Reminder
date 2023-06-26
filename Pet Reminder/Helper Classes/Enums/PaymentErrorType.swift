//
//  PaymentErrorType.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

enum PaymentErrorType: LocalizedError {
    case cantPay

    var errorDescription: String? {
        switch self {
        case .cantPay:
            return Strings.paymentCant
        }
    }
}
