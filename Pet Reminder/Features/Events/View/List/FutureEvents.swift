//
//  FutureEvents.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import EventKit

struct FutureEvents: View {

    @Environment(EventManager.self) private var manager
    var body: some View {
        Section {
            if manager.futureEvents.isEmpty {
                Text(.eventNoTitle)
            } else {
                ForEach(manager.futureEvents, id: \.self) { event in
                    NavigationLink(value: event) {
                        SingleEvent(event: event)
                    }
                    .padding(.horizontal, .spacing4)
                    .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text(.upcomingTitle)
        }
    }
}

#if DEBUG
#Preview {
    FutureEvents()
        .environment(EventManager.demo)
}
#endif
