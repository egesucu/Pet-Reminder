//
//  NotificationEnvironment.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.05.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI

private struct NotificationEnvironmentKey: EnvironmentKey {
    static let defaultValue = NotificationManager.shared
}

extension EnvironmentValues {
    var notification: NotificationManager {
        get { self[NotificationEnvironmentKey.self] }
        set { self[NotificationEnvironmentKey.self] = newValue }
    }
}

extension View {
    func notification(_ notificationManager: NotificationManager) -> some View {
        environment(\.notification, notificationManager)
            .environment(notificationManager)
    }
}

extension Scene {
    func notification(_ notificationManager: NotificationManager) -> some Scene {
        environment(\.notification, notificationManager)
            .environment(notificationManager)
    }
}
