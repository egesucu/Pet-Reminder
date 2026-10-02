//
//  Events.swift
//  Events
//
//  Created by Ege Sucu on 11.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import EventKit

struct Events: View {
    @Environment(EventManager.self) private var manager
    @Binding var selectedEvent: EKEvent?

    var body: some View {
        if manager.status == .authorized {
            List(selection: $selectedEvent) {
                TodaysEvents()
                    .environment(manager)
                    .transition(.slide)
                FutureEvents()
                    .environment(manager)
                    .transition(.slide)
            }
            .refreshable(action: reloadEvents)
        }
    }
}

// MARK: - Helpers
private extension Events {

    func reloadEvents() async {
        await manager.reloadEvents()
    }
}

#if DEBUG
#Preview {
    Events(selectedEvent: .constant(nil))
        .environment(EventManager.demo)
}
#endif
