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
            ForEach(dates, id: \.self){ date in
                Section {
                    ForEach(eventVM.events.filter({ $0.startDate == date }),
                            id: \.eventIdentifier){ event in
                        EventView(event: event)
                            .padding([.leading, .trailing])
                            .listRowSeparator(.hidden)
                    }.listRowBackground(Color.clear)
                } header: {
                    Text(convertDate(date: date))
                }
                
            }
        }.onAppear {
            self.getDates()
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
