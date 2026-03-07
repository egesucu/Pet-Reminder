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
        ZStack(alignment: .topTrailing) {
            ESEventDetailView(event: event)
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .tint(.accent)
            })
            .offset(x: PROffset.closeButtonX, y: PROffset.closeButtonY)

        }
    }
}

#if DEBUG
#Preview {
    SheetContent(event: .init(eventStore: .init()))
}
#endif
