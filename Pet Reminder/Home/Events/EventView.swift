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
    
    let eventManager = EventManager()
    
    var body: some View{
        ZStack(alignment: .leading) {
            Rectangle().fill(Color(.systemBackground))
            HStack{
                Rectangle()
                    .fill(Color(.systemGreen))
                    .frame(width: 5)
                Text(dateString)
                    .font(.largeTitle)
                VStack(alignment: .leading){
                    Text(eventTitle)
                        .font(.title)
                    if event.location != nil {
                        Text(event.location!)
                    }
                }
                if event.location != nil {
                    Image(systemName: "location.circle.fill").foregroundColor(.green)
                        .font(.headline)
                }
                
            }
            .onAppear(perform: {
                fillData()
            })
        }
        .onTapGesture {
            self.showWarningForCalendar = true
        }
        
        .alert("This will open the event on your Calendar.",isPresented: $showWarningForCalendar) {
            Button("OK",role: .cancel){
                print("\(String(describing: event.url))")
                let url = event.url ?? URL(string: "calshow://")!
                if (UIApplication.shared.canOpenURL(url)){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            }
            
           
            
            
            
        }
        .padding(10)
        .shadow(radius: 8)
    }
    
    func fillData(){
        self.eventTitle = event.title
        
        if event.isAllDay{
            self.dateString = "All Day"
        } else {
            self.dateString = "\(event.startDate.formatted(.dateTime.hour().minute())) - \(event.endDate.formatted(.dateTime.hour().minute()))"
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
