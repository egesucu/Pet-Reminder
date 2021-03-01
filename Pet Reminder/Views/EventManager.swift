//
//  EventManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.12.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import EventKit

class EventManager : ObservableObject{
    
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
                
                self.findCalendar()
                
            } else {
                print("How did I reach here?")
            }
        }
    }
    
    func findCalendar(){
        let calendars = self.eventStore.calendars(for: .event)
        debugPrint(calendars)
        if let petCalendar = calendars.first(where: {$0.title == "Pet Reminder"}){
            self.loadEvents(from: petCalendar)
        } else {
            self.createCalendar()
        }
        
    }
    
    func createCalendar() {
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "Pet Reminder"
        
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents{
            calendar.source = defaultCalendar.source
        }
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func loadEvents(from calendar : EKCalendar){
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if status == .authorized {
            
            let startDate = Date()
            let endDate = Date(timeIntervalSinceNow: 60*60*24*180)
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
            
            DispatchQueue.main.async {
                self.events = self.eventStore.events(matching: predicate)
            }
           
            
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
        
        let calendars = eventStore.calendars(for: .event)
        
        if let petCalendar = calendars.first(where: {$0.title == "Pet Reminder"}) {
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.title = name
            newEvent.startDate = start
            newEvent.endDate = end
            newEvent.calendar = petCalendar
            newEvent.addAlarm(EKAlarm(relativeOffset: -60*10))
            newEvent.notes = "This event is created by Pet Reminder app."
            
            do {
                try eventStore.save(newEvent, span: .thisEvent)
                print("Event Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
    
    
}

