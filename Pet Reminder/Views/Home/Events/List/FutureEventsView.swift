//
//  FutureEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct FutureEventsView: View {
    
    @ObservedObject var eventVM : EventManager
    
    var body: some View {
        Section{
            ForEach(eventVM.events.filter({ Calendar.current.isDateLater(date: $0.startDate) }),id: \.eventIdentifier) { event in
                EventView(event: event,eventVM: eventVM)
                    .padding([.leading, .trailing],5)
                    .listRowSeparator(.hidden)
            }
        } header: {
            Text("upcoming_title")
        }
    }
}

struct FutureEventsView_Previews: PreviewProvider {
    static var previews: some View {
        FutureEventsView(eventVM: .init(isDemo: true))
    }
}
