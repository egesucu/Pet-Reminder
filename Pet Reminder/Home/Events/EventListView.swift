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
        
        VStack{
            HStack {
                Text("Up Next")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                AddEventButton()
            }
            .padding()
            Spacer()
            ShowEventView()
            Spacer()
        }
        .onAppear(perform: {
            eventVM.reloadEvents()
        })
        
    }
    
    @ViewBuilder
    func ShowEventView() -> some View {
        if eventVM.events.isEmpty {
            EmptyEventView()
        } else {
            MultipleEventsView(eventVM: eventVM)
        }
    }
    
    func AddEventButton() -> some View {
        
        Button(action: {
            feedback.notificationOccurred(.success)
            showAddEvent.toggle()
        }, label: {
            
            Label("Add Event", systemImage: "plus.circle.fill")
                .font(.title)
                .labelStyle(IconOnlyLabelStyle())
                .foregroundColor(.white)
                .padding(5)
                .background(LinearGradient(gradient: Gradient(colors:[Color(.systemGreen), Color(.systemTeal)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(60)
        })
        .sheet(isPresented: $showAddEvent, onDismiss: {
            eventVM.reloadEvents()
            eventVM.objectWillChange.send()
        }) {
            AddEventView(feedback: feedback)
        }
        .hoverEffect()
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
                    EventView(event: event, startDateInString: eventVM.convertDateToString(date: event.startDate,isAllday: event.isAllDay), endDateInString: eventVM.convertDateToString(date: event.endDate,isAllday: event.isAllDay), eventVM: eventVM)
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
        EventListView()
    }
}
