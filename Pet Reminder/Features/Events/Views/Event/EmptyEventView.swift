//
//  EmptyEventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI


struct EmptyEventView: View {

    @Environment(EventManager.self) private var manager

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
            await manager.reloadEvents()
        }
    }
}

#Preview {
    EmptyEventView()
        .environment(EventManager.demo)
}
