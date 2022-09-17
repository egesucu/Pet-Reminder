//
//  EventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
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
            Rectangle().fill(Color(.clear)).shadow(radius: 8)
            VStack(alignment: .center){
                Text(eventTitle)
                    .font(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 100).fill(tintColor)
                    Text(dateString)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(tintColor.isDarkColor ? .white : .black)
                }
                .frame(maxWidth: 130)
            }
        }
        .onAppear(perform: {
            fillData()
        })
        .onTapGesture {
            self.showWarningForCalendar = true
        }
        .sheet(isPresented: $showWarningForCalendar, onDismiss: {
            fillData()
            eventVM.reloadEvents()
        }, content: {
            ESEventDetailView(event: event)
        })
        .padding(10)
    }
    
    func fillData(){
        self.eventTitle = event.title
        let eventDate = event.startDate
            .formatted(.dateTime.day().month(.twoDigits).year())
        if event.isAllDay{
            if Calendar.current.isDateInToday(event.startDate){
                self.dateString = NSLocalizedString("all_day_title", comment: "")
            } else {
                self.dateString = "\(eventDate)" + "\n" + NSLocalizedString("all_day_title", comment: "")
            }
            
        } else {
            if Calendar.current.isDateLater(date: event.startDate){
                self.dateString = """
\(eventDate)
\(event.startDate.formatted(.dateTime.hour().minute())) - \(event.endDate.formatted(.dateTime.hour().minute()))
"""
            } else {
                self.dateString = "\(event.startDate.formatted(.dateTime.hour().minute())) - \(event.endDate.formatted(.dateTime.hour().minute()))"
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
