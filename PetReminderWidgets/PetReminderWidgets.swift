import SwiftUI
import WidgetKit

@main
struct PetReminderWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetFeedingWidget()
        PetCareOverviewWidget()
    }
}

struct PetFeedingWidget: Widget {
    let kind = WidgetSnapshotStore.feedingKind
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectWidgetPet.self, provider: PetFeedingProvider()) { entry in
            PetFeedingView(entry: entry)
        }
        .configurationDisplayName("Pet's daily care")
        .description("Follow today's meals. Tap Morning or Evening to update or undo a feeding.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct PetCareOverviewWidget: Widget {
    let kind = WidgetSnapshotStore.overviewKind
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CareOverviewProvider()) { entry in
            CareOverviewView(entry: entry)
        }
        .configurationDisplayName("Your little crew")
        .description("Today's feeding progress for all your pets, together at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview("Daily care", as: .systemSmall) {
    PetFeedingWidget()
} timeline: { CareEntry.sample() }

#Preview("Your little crew", as: .systemMedium) {
    PetCareOverviewWidget()
} timeline: { CareEntry.sample() }

#Preview("Your pets", as: .systemSmall) {
    PetCareOverviewWidget()
} timeline: { CareEntry.sample() }

#Preview("All pets", as: .systemLarge) {
    PetCareOverviewWidget()
} timeline: { CareEntry.sample() }

#Preview("Lock Screen", as: .accessoryRectangular) {
    PetFeedingWidget()
} timeline: { CareEntry.sample() }
