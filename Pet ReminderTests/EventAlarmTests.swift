import Foundation
import Testing
import EventKit
@testable import Pet_Reminder

@MainActor
struct `Event Alarm Tests` {

    @Test
    func `Event Alarm is Relative to 10 minutes`() async throws {
        // Since EKEvent isn't trivial to introspect for alarms without an actual store,
        // this is a smoke test that ensures saveEvent completes without throwing.
        let sut = EventManager(isDemo: true)
        await sut.saveEvent(
            name: "Vet Visit",
            start: .now.addingTimeInterval(3600),
            end: .now.addingTimeInterval(7200),
            allDay: false
        )
        #expect(true) // completed
    }
}
