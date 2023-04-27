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
    
    var body: some View{
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color(.clear))
                .shadow(radius: 8)
            VStack(alignment: .center){
                EventTitleView(eventTitle: $eventTitle)
                EventTimeView(dateString: $dateString)
            }
        }
        .onAppear(perform: fillData)
        .onTapGesture(perform: showWarning)
        .sheet(isPresented: $showWarningForCalendar,
               onDismiss: onSheetDismiss,
               content: showEventDetail)
        .padding(10)
    }
    
    private func showEventDetail() -> some View {
        ESEventDetailView(event: event)
    }
    
    private func onSheetDismiss() {
        fillData()
        Task {
            await eventVM.reloadEvents()
        }
    }
    
    private func showWarning() {
        self.showWarningForCalendar = true
    }
    
    private func fillData() {
        self.eventTitle = event.title
        eventVM.fillEventData(event: event) { content in
            DispatchQueue.main.async {
                self.dateString = content
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = EventManager(isDemo: true)
        let event = manager.exampleEvents[0]
        return EventView(event: event, eventVM: manager)
            .frame(height: 100)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
