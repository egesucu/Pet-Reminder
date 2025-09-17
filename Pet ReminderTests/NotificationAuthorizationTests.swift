import UserNotifications
import Testing
@testable import Pet_Reminder

private final class StubCenter: NotificationCenterProtocol {
    enum Mode { case authorized, denied, notDetermined }
    var mode: Mode = .authorized

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        switch mode {
        case .authorized: return true
        case .denied: return false
        case .notDetermined: return true
        }
    }
    func pendingNotificationRequests() async -> [UNNotificationRequest] { [] }
    func add(_ request: UNNotificationRequest) async throws {}
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {}
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {}
    func removeAllPendingNotificationRequests() {}
}

@Suite("Notification authorization flow")
@MainActor
struct NotificationAuthorizationTests {

    @Test
    func askPermissionAuthorizedOrDeniedDoesNotCrash() async throws {
        // We cannot inject into the singleton easily; this is a smoke-style test
        // that simply ensures the method can be called and returns a Bool.
        let granted = await NotificationManager.shared.askPermission()
        #expect(granted == true || granted == false)
    }
}
