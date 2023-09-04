//
//  Vaccine.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation

extension Vaccine {
    
    var wrappedName: String {
        self.name ?? ""
    }
    var wrappedDate: Date {
        self.date ?? .now
    }
}
