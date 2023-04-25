//
//  Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import StoreKit
import CoreLocation

//MARK: - Array
extension Array{
    static var empty : Self { [] }
}
//MARK: - Pet
extension Pet{
    var selection: NotificationSelection {
        get{
            return NotificationSelection(rawValue: self.choice) ?? .both
        }
        set{
            choice = newValue.rawValue
        }
    }
}

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
//MARK: - LocalizedError
extension IcloudErrorType: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .icloudUnavailable:
            return NSLocalizedString("cloud_unavailable", comment: "")
        case .noIcloud:
            return NSLocalizedString("no_account", comment: "")
        case .restricted:
            return NSLocalizedString("restricted_account", comment: "")
        case .cantFetchStatus:
            return NSLocalizedString("cant_fetch_status", comment: "")
        case .unknownError(let message):
            return message
        }
    }
}
//MARK: - Date
extension Date{
    static let tomorrow : Date = {
        var today = Calendar.current.startOfDay(for: Date.now)
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        return tomorrow
    }()
    
    func eightAM() -> Self {
        return Calendar.current.startOfDay(for: self).addingTimeInterval(60*60*8)
    }
    
    func eightPM() -> Self {
        return Calendar.current.startOfDay(for: self).addingTimeInterval(60*60*20)
    }
    func convertDateToString()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter.string(from: self)
    }
    func convertStringToDate(string: String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter.date(from: string) ?? Date()
    }
}
//MARK: - Calendar
extension Calendar{
    func isDateLater(date: Date) -> Bool{
        return date >= Date.tomorrow
    }
}
//MARK: - CLLocation Delegate
extension VetViewModel: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        askLocationPermission()
    }
}
//MARK: - Color
extension Color: RawRepresentable {
    public init?(rawValue: Int) {
        let red =   Double((rawValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rawValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rawValue & 0x0000FF) / 0xFF
        self = Color(red: red, green: green, blue: blue)
    }
    public var rawValue: Int {
        let red = Int(coreImageColor.red * 255 + 0.5)
        let green = Int(coreImageColor.green * 255 + 0.5)
        let blue = Int(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }
    private var coreImageColor: CIColor {
        return CIColor(color: UIColor(self))
    }
}
//MARK: UIColor Extension
extension UIColor
{
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}

extension Color{
    var isDarkColor : Bool {
        return UIColor(self).isDarkColor
    }
    static let dynamicBlack = Color(.label)
    static let systemGreen = Color(.systemGreen)
}
