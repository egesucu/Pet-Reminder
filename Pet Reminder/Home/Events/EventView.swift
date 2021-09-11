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
    
    var event : EKEvent? = nil
    @State private var eventTitle = ""
    @State private var dateString = ""
    @State private var isShowing = false
    
    var body: some View{
        
        VStack{
            Text(eventTitle)
                .font(.largeTitle)
                .padding(.bottom, 10)
            Text(dateString)
                .font(.title2)
                .padding(.bottom)
        }
        .onAppear(perform: {
            fillData()
        })
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .gray, radius: 8, x: 4, y: 4)
    }
    
    func fillData(){
        if let event = event {
            self.eventTitle = event.title
            DispatchQueue.main.async {
                let manager = EventManager()
                self.dateString  = manager.convertDateToString(startDate: event.startDate, endDate: event.endDate)
            }
        } else {
            self.eventTitle = ""
            self.dateString = ""
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = EventManager()
        let event = manager.exampleEvents[0]
        return EventView(event: event)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
