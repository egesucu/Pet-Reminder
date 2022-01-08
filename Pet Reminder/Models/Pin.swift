//
//  VetPin.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import MapKit

struct Pin: Identifiable{
    var id = UUID()
    var item: MKMapItem
}
