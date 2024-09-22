//
//  EventFilterView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit


struct EventFilterView: View {

    @Binding var eventVM: EventViewModel
    @Binding var filteredCalendar: EKCalendar?
    
    @State private var calendars: [EKCalendar] = []

    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 150, maximum: 300))]) {
            ZStack {
                if filteredCalendar != nil {
                    Capsule()
                        .fill(Color.black.opacity(0.2))
                } else {
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                }
                Text("All")
            }
            .onTapGesture {
                withAnimation {
                    filteredCalendar = nil
                }

            }
            ForEach(calendars, id: \.calendarIdentifier) { calendar in
                ZStack {
                    if isCalendarSelected(calendar: calendar) {
                        Capsule()
                            .fill(Color(cgColor: calendar.cgColor))
                    } else {
                        Capsule()
                            .fill(Color(cgColor: calendar.cgColor).opacity(0.4))
                    }
                    Text(calendar.title)
                        .foregroundStyle(Color(cgColor: calendar.cgColor).isDarkColor ? Color.white : Color.black)
                        .multilineTextAlignment(.center)
                        .padding(.all, 5)
                }
                .onTapGesture {
                    withAnimation {
                        self.filteredCalendar = calendar
                    }
                }
            }
        }
        .task {
            calendars = await eventVM.getCalendars()
        }

    }

    func isCalendarSelected(calendar: EKCalendar) -> Bool {
        return calendar == filteredCalendar
    }
}

#Preview {
    EventFilterView(
        eventVM: .constant(
            .init(isDemo: true)
        ),
        filteredCalendar: .constant(
            .init(
                for: .event,
                eventStore: .init()
            )
        )
    )
}
