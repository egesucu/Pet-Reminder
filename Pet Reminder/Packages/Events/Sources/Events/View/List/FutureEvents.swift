import SwiftUI
import Shared

struct FutureEvents: View {
    @Environment(EventManager.self) private var manager

    var body: some View {
        ForEach(manager.futureEventDays, id: \.self) { day in
            Section {
                ForEach(manager.events(on: day), id: \.self) { event in
                    NavigationLink(value: event) { SingleEvent(event: event) }
                }
            } header: {
                Text(day.formatted(date: .complete, time: .omitted))
            }
        }
    }
}
