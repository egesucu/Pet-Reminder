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

struct EventView : View {
    
    var event : EKEvent
    var startDateInString : String
    var endDateInString : String
    var eventVM : EventManager

    @State private var isShowing = false
    
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
        .modifier(CustomContextMenu(isShowing: $isShowing, eventVM: eventVM, event: event))
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
        EventsView()
        //        AddEventView()
    }
}


struct CustomContextMenu : ViewModifier{
    
    @Binding var isShowing: Bool
    var eventVM:EventManager
    var event: EKEvent
    
    func body(content: Content) -> some View {
        
        if #available(iOS 15, *) {
//            content
//                .contextMenu(ContextMenu(menuItems: {
//                    Button("Remove", role: .destructive) {
//                        withAnimation {
//                            self.isShowing.toggle()
//                        }
//                        self.eventVM.removeEvent(event: event)
//                        self.eventVM.reloadEvents()
//                        self.eventVM.objectWillChange.send()
//                    }
//            Divider()
//                    Button(action: {
//                    }, label: {
//                        Label("Cancel", systemImage: "xmark.circle.fill")
//                            .labelStyle(TitleOnlyLabelStyle())
//                    })
//
//                }))
//
//
        } else {
            content
                .contextMenu(ContextMenu(menuItems: {
                    Button(action: {
                        withAnimation {
                            self.isShowing.toggle()
                        }
                        self.eventVM.removeEvent(event: event)
                        self.eventVM.reloadEvents()
                        self.eventVM.objectWillChange.send()
                    }, label: {
                        Label("Remove", systemImage: "xmark.bin.fill")
                    })
                    Divider()
                    Button(action: {
                    }, label: {
                        Label("Cancel", systemImage: "xmark.circle.fill")
                            .labelStyle(TitleOnlyLabelStyle())
                    })
                    
                }))
        }
    }
}
