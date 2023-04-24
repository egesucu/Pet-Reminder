//
//  StoreManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.09.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import StoreKit

class StoreManager : NSObject, ObservableObject{
    
    @Published var products : [SKProduct] = []
    @Published var state : SKPaymentTransactionState?
    var request : SKProductsRequest!
    var userCanPurchase = SKPaymentQueue.canMakePayments()
    let productIDs = ["pet_reminder_tea_donate","pet_reminder_food_donate"]
    
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
