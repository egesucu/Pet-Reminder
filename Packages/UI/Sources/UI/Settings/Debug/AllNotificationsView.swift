//
//  AllNotificationsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

public struct AllNotificationsView: View {

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    public var body: some View {
        List {
            ForEach(notificationManager?.notifications ?? [], id: \.identifier) { notification in
                VStack {
                    Text(notification.debugDescription)
                }
            }
        }
        .task {
            await notificationManager?.getNotifications()
        }
    }

}

#Preview {
    AllNotificationsView()
        .environment(NotificationManager())
}
