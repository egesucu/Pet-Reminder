//
//  TodaysEvents.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI
import EventKit

struct TodaysEvents: View {

    @Environment(EventManager.self) private var manager
    var body: some View {
        Section {
            if manager.todaysEvents.isEmpty {
                Text(SharedStrings.resource("Nothing scheduled today"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(manager.todaysEvents, id: \.self) { event in
                    NavigationLink(value: event) {
                        SingleEvent(event: event)
                    }
                    .padding(.horizontal, .spacing4)
                    .listRowSeparator(.hidden)
                }
            }
        } header: {
            Text(SharedStrings.today)
        }
    }
}

#if DEBUG
#Preview {
    TodaysEvents()
        .environment(EventManager.demo)
}
#endif
