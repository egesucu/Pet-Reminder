//
//  StoreManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import StoreKit

enum PaymentError: String,Error{
    case cantPay = "payment_cant"
    
    func localizedString() -> String {
            return NSLocalizedString(self.rawValue, comment: "")
        }

        static func getTitleFor(title:PaymentError) -> String {
            return title.localizedString()
        }
}


class StoreManager : NSObject, ObservableObject{
    
    @Published var products : [SKProduct] = []
    @Published var state : SKPaymentTransactionState?
    var request : SKProductsRequest!
    var userCanPurchase = SKPaymentQueue.canMakePayments()
    let productIDs = ["pet_reminder_donate_tea","pet_reminder_donate_food"]
    
    func addManagerToPayment(manager: StoreManager){
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
    
    func checkAvailability(completion: @escaping (Result<Bool,PaymentError>) -> Void){
        if userCanPurchase{
            completion(.success(true))
        } else {
            completion(.failure(.cantPay))
        }
    }
    
    func purchaseProduct(_ product: SKProduct){
        if userCanPurchase{
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func clearPreviousPurchases(){
        productIDs.forEach { id in
            UserDefaults.standard.removeObject(forKey: id)
        }
        objectWillChange.send()
    }

}

//MARK: - SKProductsrequestDelegate
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

//MARK: - SKPaymentTransactionObserver
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
extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
