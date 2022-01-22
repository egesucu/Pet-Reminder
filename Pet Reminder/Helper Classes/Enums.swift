//
//  Enums.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import Foundation

enum NotificationType: String{
    case morning
    case evening
    case birthday
}

enum PaymentError: String,Error{
    case cantPay = "payment_cant"
    
    func localizedString() -> String {
            return NSLocalizedString(self.rawValue, comment: "")
        }

        static func getTitleFor(title:PaymentError) -> String {
            return title.localizedString()
        }
}

enum Selection: Int64 {
    case both
    case morning
    case evening
}

enum IcloudError: Error{
    case icloudUnavailable
    case noIcloud
    case restricted
    case cantFetchStatus
    case unknownError(String)
    
}

enum IcloudResult{
    case success
    case error(IcloudError)
}
