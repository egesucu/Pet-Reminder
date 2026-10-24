import SwiftUI
import Shared

struct EventFilterMenu: ToolbarContent {
    @Environment(EventManager.self) private var manager

    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Menu {
                Picker(selection: Binding<String?>(
                    get: { manager.selectedCalendar?.id },
                    set: { id in manager.selectedCalendar = manager.calendars.first { $0.id == id } }
                )) {
                    if let pet = manager.petCalendar { option(pet) }
                    Text(SharedStrings.resource("All Calendars")).tag(nil as String?)
                    ForEach(manager.calendars.filter { $0.id != manager.petCalendar?.id }) { option($0) }
                } label: {
                    Text(SharedStrings.resource("Calendar"))
                }
                .pickerStyle(.inline)
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text(selectedCalendarTitle)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .accessibilityHidden(true)
                }
            }
            .menuOrder(.fixed)
            .accessibilityLabel(Text(SharedStrings.resource("Calendar")))
            .accessibilityValue(selectedCalendarTitle)
        }
    }

    private var selectedCalendarTitle: String {
        manager.selectedCalendar?.title ?? String(localized: SharedStrings.resource("All Calendars"))
    }

    private func option(_ calendar: EventCalendar) -> some View {
        Label {
            Text(calendar.title)
        } icon: {
            // UIKit menus otherwise apply the app tint to template symbols.
            Image(uiImage: colorDot(calendar.color)).renderingMode(.original)
        }
        .tag(Optional(calendar.id))
    }

    private func colorDot(_ color: Color) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 14, height: 14)).image { context in
            UIColor(color).setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 12, height: 12))
        }
    }
}
