//
//  PetManager+Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation

extension Pet{
    
    var selection: Selection {
        get{
            return Selection(rawValue: self.choice) ?? .both
        }
        set{
            choice = newValue.rawValue
        }
    }
}
