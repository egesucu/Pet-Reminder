//
//  EventsView.swift
//  EventsView
//
//  Created by Ege Sucu on 11.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import Foundation

struct EventsView: View {
    
    @ObservedObject var eventVM : EventManager
    
    @State private var dates = [Date]()
    
    var body: some View {
        List{
            Section{
                ForEach(eventVM.events.filter({ Calendar.current.isDateInToday($0.startDate)}), id: \.eventIdentifier) { event in
                    EventView(event: event)
                        .padding([.leading, .trailing],5)
                        .listRowSeparator(.hidden)
                }.listRowBackground(Color.clear)
            } header: {
                Text("Today")
            }
            
            Section{
                ForEach(eventVM.events.filter({ ($0.startDate > Calendar.current.nextDate(after: .now, matching: DateComponents(hour: 0), matchingPolicy: .nextTime)! )}),id: \.eventIdentifier) { event in
                    EventView(event: event)
                        .padding([.leading, .trailing],5)
                        .listRowSeparator(.hidden)
                }.listRowBackground(Color.clear)
            } header: {
                Text("Upcoming Events")
            }
        }.onAppear {
            self.getDates()
        }.refreshable {
            eventVM.reloadEvents()
        }
    }
    
    func getDates(){
        let events = eventVM.events
        let dates = events.map({ $0.startDate})
        self.dates = removeDuplicates(from: dates)
    }
    
    func removeDuplicates(from array: [Date?])-> [Date]{
        var temp = [Date]()
        array.forEach { date in
            if let date = date{
                temp.append(date)
            }
        }
        temp = Array(Set(temp)).sorted()
        return temp
    }
    
    func convertDate(date: Date)->String{
        return date.formatted(.dateTime.day().month().year().weekday())
    }
}
