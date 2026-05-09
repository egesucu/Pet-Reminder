//
//  AllNotifications.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct AllNotifications: View {

    @Environment(\.notification) private var notificationManager: NotificationManager

    var body: some View {
        List {
            ForEach(notificationManager.notifications, id: \.identifier) { notification in
                VStack {
                    Text(notification.debugDescription)
                }
            }
        }
        .task {
            await notificationManager.refreshNotifications()
        }
    }

}

#if DEBUG
#Preview {
    AllNotifications()
        .notification(NotificationManager.shared)
}
#endif
