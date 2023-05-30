//
//  DateExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation

extension Date{
    static let tomorrow : Date = {
        var today = Calendar.current.startOfDay(for: Date.now)
        var tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        return tomorrow
    }()
    
    func eightAM() -> Self {
        return Calendar.current.startOfDay(for: self).addingTimeInterval(60*60*8)
    }
    
    func eightPM() -> Self {
        return Calendar.current.startOfDay(for: self).addingTimeInterval(60*60*20)
    }
    func convertDateToString()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter.string(from: self)
    }
    func convertStringToDate(string: String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        return formatter.date(from: string) ?? Date()
    }
    
    func printTime() -> String {
        return self.formatted(.dateTime.hour().minute())
    }
    
    func printDate() -> String {
        return self.formatted(.dateTime.day()
            .month(.twoDigits).year())
    }
}
//MARK: - Calendar
extension Calendar{
    func isDateLater(date: Date) -> Bool{
        return date >= Date.tomorrow
    }
}
