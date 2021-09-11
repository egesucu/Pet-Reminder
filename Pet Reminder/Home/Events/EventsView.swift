//
//  EventsView.swift
//  EventsView
//
//  Created by Ege Sucu on 11.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

struct EventsView: View {
    
    @ObservedObject var eventVM = EventManager()
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                ForEach(eventVM.events, id: \.eventIdentifier) { event in
                    EventView(event: event)
                        .padding()
                        .transition(.scale)
                }
                .padding([.top,.bottom],5)
            }
        }
    }
}
