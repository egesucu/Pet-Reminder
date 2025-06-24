//
//  VetPin.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import MapKit

public struct Pin: Identifiable, Hashable {
    public var item: MKMapItem
    
    public init(item: MKMapItem) {
        self.item = item
    }

    public var id: String {
        "\(latitude)-\(longitude)-\(name)"
    }

    public var fullAdress: String? {
        item.address?.fullAddress
    }

    public var phoneNumber: String? {
        item.phoneNumber
    }

    public var location: CLLocation {
        item.location
    }

    public var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }

    public var latitude: CLLocationDegrees {
        coordinate.latitude
    }

    public var longitude: CLLocationDegrees {
        coordinate.longitude
    }

    public var name: String {
        item.name ?? ""
    }
}

extension Pin: CustomStringConvertible {
    public var description: String {
        "\(name) at \(coordinate.latitude), \(coordinate.longitude)"
    }
}
