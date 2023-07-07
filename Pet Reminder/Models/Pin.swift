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
    var id = UUID()
    var item: MKMapItem
}
