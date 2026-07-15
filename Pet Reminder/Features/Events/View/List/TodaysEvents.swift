//
//  TodaysEvents.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct TodaysEvents: View {

    @Environment(EventManager.self) private var manager

    var body: some View {
        Section {
            if manager.todaysEvents.isEmpty {
                Text(.eventNoTitle)
            } else {
                ForEach(manager.todaysEvents, id: \.self) { event in
                    SingleEvent(event: event)
                        .environment(manager)
                        .padding(.horizontal, .spacing4)
                        .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text(.todayTitle)
        }
    }
}

#if DEBUG
#Preview {
    TodaysEvents()
        .environment(EventManager.demo)
}
#endif
