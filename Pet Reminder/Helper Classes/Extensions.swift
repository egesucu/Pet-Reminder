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
import EventKit
import MapKit

//MARK: - Array
extension Array{
    static var empty : Self { [] }
}

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
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
    
    func printTime() -> String {
        return self.formatted(.dateTime.hour().minute())
    }
    
    func printDate() -> String {
        return self.formatted(.dateTime.day()
            .month(.twoDigits).year())
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

extension LocalizedStringKey {
    static let cancel: Self = "save"
    static let save: Self = "cancel"
}

extension Strings {
    internal static let demoVaccines = ["Pulvarin","Alvarin","Gagarin","Aclor","Silverin", "Volverine"]
    internal static let placeholderVaccine = "Pulvarin"
    internal static let simulationError = "Simulation does not support User Location"
    internal static let demo = "Demo"
    internal static let petSaved = "petSaved"
    internal static let tintColor = "tint_color"
    internal static let doggo = "Doggo"
    internal static let viski = "Viski"
    internal static let donateTeaID = "pet_reminder_tea_donate"
    internal static let donateFoodID = "pet_reminder_food_donate"
    
    internal static func footerLabel(_ p1: Any) -> String {
        return "© Ege Sucu \(p1)"
    }
    internal static func notificationIdenfier(_ p1: Any, _ p2: Any) -> String {
      return "\(p1)-\(p2)-notification"
    }
    
    internal static func demoEvent(_ p1: Any) -> String {
        return "Demo Event \(p1)"
    }
    
    internal static let petReminder = "Pet Reminder"
    
}

internal enum SFSymbols {
    internal static let sun = "Sun"
    internal static let xmarkSealFill = "xmark.seal.fill"
    internal static let pawprintCircleFill = "pawprint.circle.fill"
    internal static let xcircleFill = "x.circle.fill"
    internal static let person = "person.crop.circle"
    internal static let personSelected = "person.crop.circle.fill"
    internal static let list = "list.bulet"
    internal static let listSelected = "list.bullet.indent"
    internal static let map = "map"
    internal static let mapSelected = "map.fill"
    internal static let settings = "gearshape"
    internal static let settingsSelected = "gearshape.fill"
    internal static let calendar = "calendar.badge.plus"
    internal static let morning = "sun.max.circle.fill"
    internal static let evening = "moon.stars.circle.fill"
    internal static let birthday = "birthday.cake.fill"
    internal static let close = "xmark.circle.fill"
    internal static let add = "plus.circle.fill"
    internal static let vaccine = "syringe.fill"
    internal static let eveningToggle = "moon.circle"
    internal static let eveningToggleSelected = "moon.circle.filled"
    internal static let checked = "checkmark.square"
    internal static let notChecked = "square"
    internal static let morningToggle = "sun.max.circle"
    internal static let morningToggleSelected = "sun.max.circle.fill"
    
}

extension String {
    static func formatEventDateTime(current: Bool, allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return current ? Strings.allDayTitle : String.futureDateTimeFormat(allDay: allDay, event: event)
        } else {
            return current ? String.currentDateTimeFormat(allDay: allDay, event: event) : String.futureDateTimeFormat(allDay: allDay, event: event)
        }
    }
    
    static func futureDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return "\(event.startDate.printDate()) \(Strings.allDayTitle)"
        } else {
            return "\(event.startDate.printDate()) \(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }
    
    static func currentDateTimeFormat(allDay: Bool, event: EKEvent) -> Self {
        if allDay {
            return Strings.allDayTitle
        } else {
            return "\(event.startDate.printTime()) - \(event.endDate.printTime())"
        }
    }
}


extension View {

    func openURLWithMap(latitude: CGFloat, longitude: CGFloat, application: MapApplication) {
        switch application {
            case .google:
                guard let deeplink = URLDefinitions.googleMapsDeeplinkURL else { return }
                if UIApplication.shared.canOpenURL(deeplink) {
                    let url = URL(string: String(format: URLDefinitions.googleMapsLocationString, latitude, longitude))
                    if let url {
                        UIApplication.shared.open(url)
                    }
                } else {
                    if let url = URLDefinitions.googleMapsAppStoreURL {
                        UIApplication.shared.open(url)
                    }
                }
            case .apple:
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let placemark = MKPlacemark(coordinate: coordinate)
                let item = MKMapItem(placemark: placemark)
                item.openInMaps()
            case .yandex:
                guard let deeplink = URLDefinitions.yandexMapsDeeplinkURL else { return }
                if UIApplication.shared.canOpenURL(deeplink) {
                    let url = URL(string: String(format: URLDefinitions.yandexMapsLocationString, latitude, longitude))
                    if let url {
                        UIApplication.shared.open(url)
                    }
                } else {
                    if let url = URLDefinitions.yandexMapsAppStoreURL {
                        UIApplication.shared.open(url)
                    }
                }
        }
    }
}

struct URLDefinitions {
    static let googleMapsAppStoreURL = URL(string: "https://apps.apple.com/us/app/google-maps/id585027354")
    static let googleMapsDeeplinkURL = URL(string: "comgooglemaps://")
    static let googleMapsLocationString = "comgooglemaps://?saddr=&daddr=%ld,%ld"
    static let yandexMapsAppStoreURL = URL(string: "https://itunes.apple.com/ru/app/yandex.navigator/id474500851")
    static let yandexMapsDeeplinkURL = URL(string: "yandexnavi://")
    static let yandexMapsLocationString = "yandexnavi://build_route_on_map?lat_to=%ld&lon_to=%ld"
}

enum MapApplication: String, CaseIterable {
    case google = "Google Maps"
    case apple = "Maps"
    case yandex = "Yandex Maps"
}
