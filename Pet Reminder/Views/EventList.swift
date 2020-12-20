//
//  EventList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

class EventList : ObservableObject{
    
    @Published var events : [EKEvent] = [EKEvent]()
    let eventStore = EKEventStore()
    
    init() {
        requestEvents()
    }
    
    func requestEvents(){
        
        eventStore.requestAccess(to: .event) { (success, error) in
            if let error = error{
                print(error.localizedDescription)
            } else if success{
                
                if let petCalendar = self.eventStore.calendar(withIdentifier: "Pet Reminder"){
//                    load all events
                    self.loadEvents(from: petCalendar)
                } else {
//                    create a calendar account
                    
                }
   
                
            } else {
                print("How did I reach here?")
            }
        }
    }
    
    func loadEvents(from calendar : EKCalendar){
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if status == .authorized {
            
            let startDate = Date()
            let endDate = Date(timeIntervalSinceNow: 60*60*24*180)
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
            events = eventStore.events(matching: predicate)
            
        } else {
            requestEvents()
        }
    }
    
    func convertDateToString(date: Date)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MMMM HH:mm"
        return dateFormatter.string(from: date)
    }
    
    
    func saveEvent(name : String, start : Date, end: Date){
        
        if let calendar = eventStore.calendar(withIdentifier: "Pet Reminder") {
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.title = name
            newEvent.startDate = start
            newEvent.endDate = end
            newEvent.calendar = calendar
            newEvent.addAlarm(EKAlarm(relativeOffset: -60*10))
            newEvent.notes = "This event is created by Pet Reminder app."
            
            do {
                try eventStore.save(newEvent, span: .thisEvent)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
    
    
}
