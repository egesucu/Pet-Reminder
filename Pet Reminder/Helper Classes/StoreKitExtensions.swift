//
//  StoreKitExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import StoreKit


//MARK: - SKProducts Delegate
extension StoreManager: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.isEmpty{
            print("No Product is present.")
        } else {
            for product in response.products{
                DispatchQueue.main.async {
                    self.products.append(product)
                }
            }
        }
        response.invalidProductIdentifiers.forEach({ print("This ID is invalid: ",$0)})
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error occured: ",error)
    }
}
//MARK: - SKPayment Observer
extension StoreManager: SKPaymentTransactionObserver{
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState{
            case .purchasing:
                state = .purchasing
            case .purchased:
                state = .purchased
                UserDefaults.standard.set(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .failed:
                state = .failed
                queue.finishTransaction(transaction)
            case .deferred:
                state = .deferred
                queue.finishTransaction(transaction)
            case .restored:
                state = .restored
                UserDefaults.standard.set(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            default:
                queue.finishTransaction(transaction)
            }
        }
        objectWillChange.send()
    }
}
//MARK: - SKProduct
extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
