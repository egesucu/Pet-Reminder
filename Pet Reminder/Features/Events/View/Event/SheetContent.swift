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

struct SheetContent: View {
    @Environment(\.dismiss) var dismiss

    var event: EKEvent

    var body: some View {
        NavigationStack {
            ESEventDetail(event: event)
                .navigationTitle(event.title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark", action: dismiss.callAsFunction)
                    }
                }
        }
    }
}

#if DEBUG
#Preview {
    SheetContent(event: .init(eventStore: .init()))
}
#endif
