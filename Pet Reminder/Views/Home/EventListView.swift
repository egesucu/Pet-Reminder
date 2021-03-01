//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

struct EventsView : View {
    
    @StateObject var eventVM = EventManager()
    @State private var showAddEvent = false
    
    
    var addEventButton : some View{
        Button(action: {
            showAddEvent.toggle()
        }, label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Event").bold()
            }
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors:[Color(.systemGreen), Color(.systemTeal)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(60)
        })
        .hoverEffect()
        
        .sheet(isPresented: $showAddEvent, onDismiss: {
            eventVM.reloadEvents()
            eventVM.objectWillChange.send()
        }) {
            AddEventView()
        }
    }
    
    
    var body: some View{
        
        VStack{
            
            HStack {
                Text("Up Next")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                addEventButton
            }
            .padding()
            Spacer()
            
            #if targetEnvironment(simulator)
            MultipleEventsView(eventVM: eventVM)
            #else
            eventVM.events.isEmpty ? AnyView(EmptyEventView()) : AnyView(MultipleEventsView(eventVM: eventVM))
            #endif
            Spacer()
        }
        
    }
}

struct EventView : View {
    
    var event : EKEvent
    var startDateInString : String
    var endDateInString : String
    
    var body: some View{
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors:[Color(.systemGreen), Color(.systemTeal)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
            VStack{
                Text(event.title)
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
                if event.isAllDay{
                    Text(startDateInString)
                        .font(.body)
                        .multilineTextAlignment(.center)
                } else {
                    HStack {
                        Text(startDateInString)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Text("-")
                        Text(endDateInString)
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                }
                
            }
            .padding()
            
            
        }
        .padding(.bottom, 10)
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
    
    
    var saveButton : some View {
        Button(action: {
            
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
    
    var cancelButton : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            eventName = ""
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.systemGreen))
            
        })
    }
    
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
                            DatePicker("Event End Date", selection: $eventEndDate)
                        }
                    }
                }
                .accentColor(Color(.systemGreen))
                .navigationTitle(Text("Add a New Event"))
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
            }
        }
    }
}



struct EmptyEventView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("There is no event")
                .font(.headline)
                .padding()
            Spacer()
        }
    }
}

struct MultipleEventsView: View {
    
   
    @State private var deleteEvent = false
    @State private var isShowing = false
    
    @ObservedObject var eventVM: EventManager
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 0) {
                
                #if targetEnvironment(simulator)
                ForEach(eventVM.exampleEvents, id: \.self) { event in
                    if isShowing {
                        EventView(event: event, startDateInString: eventVM.convertDateToString(date: event.startDate), endDateInString: eventVM.convertDateToString(date: event.endDate))
                            .padding([.leading,.trailing])
                            .contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    withAnimation {
                                        self.isShowing.toggle()
                                    }
                                    self.eventVM.removeEvent(event: event)
                                    self.eventVM.reloadEvents()
                                    self.eventVM.objectWillChange.send()
                                }, label: {
                                    Text("Remove")
                                })
                                Text("Cancel")
                               
                            }))
                    }
                    
                }
                .padding([.top,.bottom],10)
                #else
                ForEach(eventVM.events, id: \.self) { event in
                    EventView(event: event, startDateInString: eventVM.convertDateToString(date: event.startDate), endDateInString: eventVM.convertDateToString(date: event.endDate))
                        .padding()
                        .transition(.scale)
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                withAnimation {
                                    self.isShowing.toggle()
                                }
                                self.eventVM.removeEvent(event: event)
                                self.eventVM.reloadEvents()
                                self.eventVM.objectWillChange.send()
                            }, label: {
                                Image(systemName: "xmark.bin.fill")
                                Text("Remove")
                            })
                            Button(action: {}, label: {
                                Text("Cancel")
                            })
                           
                        }))
                }
                .padding([.top,.bottom],20)
                #endif
                
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
//        AddEventView()
    }
}
