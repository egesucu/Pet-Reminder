//
//  MapApplication.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public enum MapApplication: String, CaseIterable {
    case google = "Google Maps"
    case apple = "Maps"
    case yandex = "Yandex Maps"
}

extension MapApplication {
    public var name: String {
        self.rawValue
    }

    public var deeplinkURL: URL? {
        switch self {
        case .google:
            URLDefinitions.googleMapsDeeplinkURL
        case .apple:
            nil
        case .yandex:
            URLDefinitions.yandexMapsDeeplinkURL
        }
    }

    public var appStoreURL: URL? {
        switch self {
        case .google:
            URLDefinitions.googleMapsAppStoreURL
        case .apple:
            nil
        case .yandex:
            URLDefinitions.yandexMapsAppStoreURL
        }
    }

    public func destinationURL(latitude: Double, longitude: Double) -> URL? {
        switch self {
        case .google:
            URL(
                string: URLDefinitions.googleMapsLocationString(
                    latitude: latitude,
                    longitude: longitude
                )
            )
        case .apple:
            nil
        case .yandex:
            URL(
                string: URLDefinitions.yandexMapsLocationString(
                    latitude: latitude,
                    longitude: longitude
                )
            )
        }
    }
}
