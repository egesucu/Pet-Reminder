//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

struct EventListView : View {
    
    @StateObject var eventVM = EventManager()
    @State private var showAddEvent = false
    
    let feedback = UINotificationFeedbackGenerator()
    
    var body: some View{
        
        NavigationView{
            
            VStack{
                if eventVM.events.isEmpty{
                    EmptyEventView()
                } else {
                    MultipleEventsView(eventVM: eventVM)
                }
                
            }
            .navigationTitle(Text("Up Next"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddEvent.toggle() }, label: {
                        Label("Add Event", systemImage: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.green)
                    })
                        .sheet(isPresented: $showAddEvent, onDismiss: {
                            eventVM.reloadEvents()
                            
                        }) { AddEventView(feedback: feedback) }
                        .hoverEffect()
                }
            }
        }.onAppear {
            eventVM.reloadEvents()
        }
        
        
        
    }
    
}

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
                    Section(header: Text("Event Info")) {
                        TextField("Event Name", text: $eventName)
                    }
                    Section(header: Text("Event Time")) {
                        Toggle("All Day ?", isOn: $isAllDay)
                        
                        if isAllDay{
                            DatePicker("Event Date", selection: $allDayDate, displayedComponents: .date)
                        } else {
                            DatePicker("Event Start Date", selection: $eventStartDate)
                                .onChange(of: eventStartDate, perform: { value in
                                    eventEndDate = value
                                })
                            DatePicker("Event End Date", selection: $eventEndDate, in: eventStartDate...)
                        }
                    }
                }
                .accentColor(Color(.systemGreen))
                .navigationTitle(Text("Add a New Event"))
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
            Text("Save Event")
                .foregroundColor(Color(.systemGreen))
                .bold()
            
        })
    }
    
}



struct MultipleEventsView: View {
    
    @ObservedObject var eventVM: EventManager
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                ForEach(eventVM.events, id: \.eventIdentifier) { event in
                    EventView(event: event)
                        .padding()
                        .transition(.scale)
                    
                }
                .padding([.top,.bottom],20)
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventListView(eventVM: EventManager(isDemo: true))
                .previewDisplayName("Demo")
            //            EventListView()
            //                .previewDisplayName("Real")
        }
    }
}
