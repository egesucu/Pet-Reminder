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
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

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
                .tint(tintColor)
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

struct EmptyEventView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyEventView(eventVM: .init(isDemo: true))
    }
}
