/**
 Tests for the notification authorization flow through `NotificationManager` using a stub `NotificationCenterProtocol`.
 */

import UserNotifications
import Testing
@testable import Pet_Reminder

/// A stub implementation of `NotificationCenterProtocol` for testing authorization scenarios.
///
/// - `Mode` enum defines the authorization states to simulate:
///   - `.authorized`: Authorization granted.
///   - `.denied`: Authorization denied.
///   - `.notDetermined`: Authorization not yet determined, allows specifying request result.
/// - Tracks whether `requestAuthorization` was called via `didRequestAuthorization`.
/// - `requestAuthorization(options:)` behavior:
///   - Returns `true` if `mode` is `.authorized`.
///   - Returns `false` if `mode` is `.denied`.
///   - Returns `requestAuthorizationResult` if `mode` is `.notDetermined`.
/// - Other methods are stubbed with empty implementations.
private final class StubCenter: NotificationCenterProtocol {
    enum Mode { case authorized, denied, notDetermined }
    var mode: Mode = .authorized
    var didRequestAuthorization = false
    var requestAuthorizationResult = true

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        didRequestAuthorization = true
        switch mode {
        case .authorized: return true
        case .denied: return false
        case .notDetermined: return requestAuthorizationResult
        }
    }
    func pendingNotificationRequests() async -> [UNNotificationRequest] { [] }
    func add(_ request: UNNotificationRequest) async throws {}
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {}
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {}
    func removeAllPendingNotificationRequests() {}
}

@MainActor
/// Tests the behavior of `NotificationManager`'s `askPermission()` method under different 
/// authorization states:
/// - When already authorized, it should not request authorization again and return true.
/// - When denied, it should not request authorization and return false.
/// - When not determined, it should request authorization and correctly adopt the granted or denied result.
struct `Notification Authorization Tests` {

    @Test
    func `Ask Permission handles Authorization States`() async {
        // Authorized path: should not request authorization again and return true.
        let authorizedStub = StubCenter()
        authorizedStub.mode = .authorized
        let authorizedManager = NotificationManager(
            notificationCenter: authorizedStub,
            authorizationStatusProvider: { .authorized }
        )
        let authorizedResult = await authorizedManager.askPermission()
        #expect(authorizedResult == true)
        #expect(authorizedManager.lastKnownAuthorizationStatus == .authorized)
        #expect(authorizedStub.didRequestAuthorization == false)

        // Denied path: should return false without making a new request.
        let deniedStub = StubCenter()
        deniedStub.mode = .denied
        let deniedManager = NotificationManager(
            notificationCenter: deniedStub,
            authorizationStatusProvider: { .denied }
        )
        let deniedResult = await deniedManager.askPermission()
        #expect(deniedResult == false)
        #expect(deniedManager.lastKnownAuthorizationStatus == .denied)
        #expect(deniedStub.didRequestAuthorization == false)

        // Not determined path with permission granted: should call requestAuthorization and adopt the result.
        let grantingStub = StubCenter()
        grantingStub.mode = .notDetermined
        grantingStub.requestAuthorizationResult = true
        let grantingManager = NotificationManager(
            notificationCenter: grantingStub,
            authorizationStatusProvider: { .notDetermined }
        )
        let granted = await grantingManager.askPermission()
        #expect(granted == true)
        #expect(grantingManager.lastKnownAuthorizationStatus == .authorized)
        #expect(grantingStub.didRequestAuthorization == true)

        // Not determined path with permission denied: should call requestAuthorization and adopt the result.
        let denyingStub = StubCenter()
        denyingStub.mode = .notDetermined
        denyingStub.requestAuthorizationResult = false
        let denyingManager = NotificationManager(
            notificationCenter: denyingStub,
            authorizationStatusProvider: { .notDetermined }
        )
        let denied = await denyingManager.askPermission()
        #expect(denied == false)
        #expect(denyingManager.lastKnownAuthorizationStatus == .denied)
        #expect(denyingStub.didRequestAuthorization == true)
    }
}

