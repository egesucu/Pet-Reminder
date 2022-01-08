//
//  AddEventView.swift
//  AddEventView
//
//  Created by Ege Sucu on 11.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

struct AddEventView : View {
    
    @State private var eventName = ""
    @State private var allDayDate = Date()
    @State private var eventStartDate = Date()
    @State private var eventEndDate = Date()
    @State private var isAllDay = false
    @StateObject var eventVM = EventManager()
    @Environment(\.presentationMode) var presentationMode
    
    var feedback: UINotificationFeedbackGenerator
    
    var body: some View{
        
        ZStack(alignment: .topLeading) {
            NavigationView {
                Form {
                    Section(header: Text("add_event_info")) {
                        TextField("add_event_name", text: $eventName)
                    }
                    Section(header: Text("add_event_time")) {
                        Toggle("all_day_title", isOn: $isAllDay)
                        if isAllDay{
                            DatePicker("add_event_date", selection: $allDayDate, displayedComponents: .date)
                        } else {
                            DatePicker("add_event_start", selection: $eventStartDate)
                                .onChange(of: eventStartDate, perform: { value in
                                    eventEndDate = value
                                })
                            DatePicker(NSLocalizedString("add_event_end", comment: "") , selection: $eventEndDate, in: eventStartDate...)
                        }
                    }
                }
                .accentColor(Color(.systemGreen))
                .navigationTitle(Text("add_event_title"))
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SaveButton()
                    }
                })
            }
        }
    }
    
    func SaveButton() -> some View {
        Button(action: {
            feedback.notificationOccurred(.success)
            
            if isAllDay{
                self.eventVM.saveEvent(name: eventName, start: allDayDate, isAllDay: isAllDay)
                
            } else {
                self.eventVM.saveEvent(name: eventName, start: eventStartDate, end: eventEndDate)
            }
            self.eventVM.objectWillChange.send()
            self.eventVM.reloadEvents()
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("add_event_save")
                .foregroundColor(Color(.systemGreen))
                .bold()
            
        })
    }
    
}
