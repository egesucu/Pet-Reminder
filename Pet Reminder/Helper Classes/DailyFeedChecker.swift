//
//  DailyFeedChecker.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

class DailyFeedChecker{
    
    static let shared = DailyFeedChecker()
    
    
    func resetLogic(pets: FetchedResults<Pet>, context: NSManagedObjectContext) {
        
        let today = UserDefaults.standard.object(forKey: "today") as? Date
        
        if let today = today{
            
            let first = Calendar.current.startOfDay(for: today)
            let second = Calendar.current.startOfDay(for: .now)
            
            if first != second{
                removePetFeeds(pets: pets, context: context)
                UserDefaults.standard.setValue(Date.now, forKey: "today")
            } else {
            }
            
        } else {
            UserDefaults.standard.setValue(Date.now, forKey: "today")
        }
        
    }
    
    
    func removePetFeeds(pets: FetchedResults<Pet>, context: NSManagedObjectContext){
        
        DispatchQueue.main.async {
            for pet in pets{
                pet.morningFed = false
                pet.eveningFed = false
            }
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    
    
    
    
    
}
