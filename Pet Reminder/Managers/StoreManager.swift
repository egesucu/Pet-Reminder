//
//  StoreManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.09.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import StoreKit
import Observation

@Observable
class StoreManager: NSObject {

    var products: [SKProduct] = []
    var state: SKPaymentTransactionState = .failed

    @ObservationIgnored var request: SKProductsRequest = .init()
    @ObservationIgnored var userCanPurchase = SKPaymentQueue.canMakePayments()
    @ObservationIgnored let productIDs = [Strings.donateTeaID, Strings.donateFoodID]

    func addManagerToPayment(manager: StoreManager) {
        SKPaymentQueue.default().add(manager)
    }

    func userDidPurchase(_ product: SKProduct) -> Bool {
        let productID = product.productIdentifier
        let purchased = UserDefaults.standard.bool(forKey: productID)
        return purchased
    }

    func getProducts() {
        products.removeAll()
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    func checkAvailability(completion: @escaping (Result<Bool, PaymentErrorType>) -> Void) {
        if userCanPurchase {
            completion(.success(true))
        } else {
            completion(.failure(.cantPay))
        }
    }

    func purchaseProduct(_ product: SKProduct) {
        if userCanPurchase {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    func clearPreviousPurchases() {
        productIDs.forEach { id in
            UserDefaults.standard.removeObject(forKey: id)
        }
    }
}
