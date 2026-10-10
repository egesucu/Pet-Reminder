//
//  SheetContent.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKit
import Shared
import SharedUI

struct SheetContent: View {
    @Environment(\.dismiss) var dismiss

    var event: EKEvent

    var body: some View {
        NavigationStack {
            EventDetail(event: event)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(SharedStrings.resource("Close"), systemImage: "xmark", action: dismiss.callAsFunction)
                    }
                }
        }
    }
}

#if DEBUG
#Preview {
    SheetContent(event: EventManager.Demo.exampleEvents[0])
        .environment(EventManager.demo)
}
#endif
