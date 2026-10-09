//
//  EmptyEvent.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Shared
import SwiftUI

struct EmptyEvent: View {

    @Environment(EventManager.self) private var manager

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(SharedStrings.eventNoTitle)
                    .font(.headline)
                    .padding()
                Button(action: reloadEvents) {
                    Text(SharedStrings.refresh)
                }
                .tint(.accent)
                Spacer()
            }
        }
    }

    func reloadEvents() {
        Task {
            await manager.reloadEvents()
        }
    }
}

#if DEBUG
#Preview {
    EmptyEvent()
        .environment(EventManager.demo)
}
#endif
