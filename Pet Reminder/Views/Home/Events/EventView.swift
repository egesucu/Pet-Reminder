//
//  EventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit

struct EventView : View {
    
    var event : EKEvent
    @State private var eventTitle = ""
    @State private var dateString = ""
    @State private var isShowing = false
    @State private var showWarningForCalendar = false
    
    @ObservedObject var eventVM : EventManager
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View{
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color(.clear))
                .shadow(radius: 8)
            VStack(alignment: .center){
                Text(eventTitle)
                    .font(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 100)
                        .fill(tintColor)
                    Text(dateString)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(tintColor.isDarkColor ? .white : .black)
                }
                
            }
        }
        .onAppear(perform: fillData)
        .onTapGesture(perform: showWarning)
        .sheet(isPresented: $showWarningForCalendar, onDismiss: reloadView, content: {
            ESEventDetailView(event: event)
        })
        .padding(10)
    }
    
    func showWarning() {
        self.showWarningForCalendar = true
    }
    
    func reloadView() {
        fillData()
        eventVM.reloadEvents()
    }
    
    func fillData(){
        DispatchQueue.main.async {
            self.eventTitle = event.title
        }
        let eventDate = event.startDate
            .formatted(.dateTime.day().month(.twoDigits).year())
        if event.isAllDay{
            if Calendar.current.isDateInToday(event.startDate){
                DispatchQueue.main.async {
                    self.dateString = NSLocalizedString("all_day_title", comment: "")
                }
            } else {
                DispatchQueue.main.async {
                    self.dateString = "\(eventDate)" + " " + NSLocalizedString("all_day_title", comment: "")
                }
            }
            
        } else {
            if Calendar.current.isDateLater(date: event.startDate){
                DispatchQueue.main.async {
                    self.dateString = "\(eventDate) \(event.startDate.formatted(.dateTime.hour().minute())) - \(event.endDate.formatted(.dateTime.hour().minute()))"
                }
            } else {
                DispatchQueue.main.async {
                    self.dateString = "\(event.startDate.formatted(.dateTime.hour().minute())) - \(event.endDate.formatted(.dateTime.hour().minute()))"
                }
                
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = EventManager(isDemo: true)
        let event = manager.exampleEvents[0]
        return EventView(event: event, eventVM: manager)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
