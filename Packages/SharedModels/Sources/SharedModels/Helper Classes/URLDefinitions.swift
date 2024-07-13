//
//  URLDefinitions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public struct URLDefinitions {
    public static let googleMapsAppStoreURL = URL(string: "https://apps.apple.com/us/app/google-maps/id585027354")
    public static let googleMapsDeeplinkURL = URL(string: "comgooglemaps://")
    public static let googleMapsLocationString = "comgooglemaps://?saddr=&daddr=%f,%f"
    public static let yandexMapsAppStoreURL = URL(string: "https://itunes.apple.com/ru/app/yandex.navigator/id474500851")
    public static let yandexMapsDeeplinkURL = URL(string: "yandexnavi://")
    public static let yandexMapsLocationString = "yandexnavi://build_route_on_map?lat_to=%f&lon_to=%f"
}
