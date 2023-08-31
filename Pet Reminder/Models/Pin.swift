//
//  VetPin.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import MapKit

struct Pin: Identifiable {
    var item: MKMapItem

    var id: Int {
        item.hashValue
    }

    var subThoroughfare: String? {
        item.placemark.subThoroughfare
    }

    var thoroughfare: String? {
        item.placemark.thoroughfare
    }

    var locality: String? {
        item.placemark.locality
    }

    var postalCode: String? {
        item.placemark.postalCode
    }

    var phoneNumber: String? {
        item.phoneNumber
    }

    var location: CLLocation {
        item.placemark.location ?? .init()
    }

    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }

    var latitude: CLLocationDegrees {
        coordinate.latitude
    }

    var longitude: CLLocationDegrees {
        coordinate.longitude
    }

    var name: String {
        item.name ?? ""
    }
}
