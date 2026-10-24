import SwiftUI

public extension View {
    func notification(_ manager: NotificationManager) -> some View {
        environment(manager)
    }
}

public extension Scene {
    func notification(_ manager: NotificationManager) -> some Scene {
        environment(manager)
    }
}
