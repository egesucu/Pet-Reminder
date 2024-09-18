//
//  EmptyEventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI


struct EmptyEventView: View {

    var eventVM: EventManager

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("event_no_title")
                    .font(.headline)
                    .padding()
                Button(action: reloadEvents) {
                    Text("refresh")
                }
                .tint(.accent)
                Spacer()
            }
        }
    }

    func reloadEvents() {
        Task {
            await eventVM.reloadEvents()
        }
    }
}

#Preview {
    EmptyEventView(eventVM: .init(isDemo: true))
}
