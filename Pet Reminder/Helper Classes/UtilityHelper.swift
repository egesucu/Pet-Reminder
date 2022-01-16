//
//  UtilityHelper.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation

struct UtilityHelper {
    
    static let shared = UtilityHelper()
    
    
   
}

extension Date{
    static let tomorrow : Date = {
        var today = Calendar.current.startOfDay(for: Date.now)
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        return tomorrow
    }()
}

extension Calendar{
    
    func isDateLater(date: Date) -> Bool{
        return date >= Date.tomorrow
    }
}
