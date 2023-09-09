//
//  AllNotificationsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct AllNotificationsView: View {

    @State private var notificationManager = NotificationManager()

    var body: some View {
        List {
            ForEach(notificationManager.notifications.filter({ request in
                !request.identifier.contains("birthday")
            }), id: \.identifier) { notification in
                VStack {
                    Text(notification.debugDescription)
                }
            }
        }
        .task(notificationManager.getNotifications)
    }
}

#Preview {
    AllNotificationsView()
}
