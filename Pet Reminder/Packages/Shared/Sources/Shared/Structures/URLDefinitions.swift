//
//  URLDefinitions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

struct URLDefinitions {
    static let googleMapsAppStoreURL = URL(string: "https://apps.apple.com/us/app/google-maps/id585027354")
    static let googleMapsDeeplinkURL = URL(string: "comgooglemaps://")
    static func googleMapsLocationString(latitude: Double, longitude: Double) -> String {
        "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)"
    }
    static let yandexMapsAppStoreURL = URL(string: "https://itunes.apple.com/ru/app/yandex.navigator/id474500851")
    static let yandexMapsDeeplinkURL = URL(string: "yandexnavi://")
    static func yandexMapsLocationString(latitude: Double, longitude: Double) -> String {
        "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)"
    }
}
