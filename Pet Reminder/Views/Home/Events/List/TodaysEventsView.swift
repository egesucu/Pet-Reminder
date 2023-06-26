//
//  TodaysEventsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct TodaysEventsView: View {

    @ObservedObject var eventVM: EventManager

    var body: some View {
        Section {
            ForEach(eventVM.events.filter({ Calendar.current.isDateInToday($0.startDate)}), id: \.eventIdentifier) { event in
                EventView(event: event, eventVM: eventVM)
                    .padding([.leading, .trailing], 5)
                    .listRowSeparator(.hidden)
            }
        } header: {
            Text(Strings.todayTitle)
        }
    }
}

struct TodaysEventsView_Previews: PreviewProvider {
    static var previews: some View {
        TodaysEventsView(eventVM: .init(isDemo: true))
    }
}
