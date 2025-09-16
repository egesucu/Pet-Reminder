//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import Shared
import SFSafeSymbols

struct NotificationView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Pet.name) var pets: [Pet]

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {
        VStack {
            List {
                ForEach(pets, id: \.name) { pet in
                    if let notificationManager {
                        notificationSection(for: pet, notificationManager: notificationManager)
                    }
                }

            }
            .listStyle(.insetGrouped)
            .refreshable {
                await notificationManager?.refreshNotifications()
            }
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView(
                    "pet_no_pet",
                    systemSymbol: .pawprintCircle
                )
            }
        }
        .navigationTitle(Text(.notificationsTitle))
        .toolbar {
            if pets.isNotEmpty {
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        Task {
                            try? await notificationManager?.removeNotificationsIdentifiers(
                                with: notificationManager?.notifications.map { $0.identifier
                                } ?? [])
                            await fetchNotificiations()
                        }
                    } label: {
                        Text(.removeAll)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.automatic)
                }

            }
        }
        .task {
            await notificationManager?.refreshNotifications()
        }
    }

    private func createNotifications(for pet: Pet) async {
        await notificationManager?
            .createNotifications(
                for: pet,
                morningTime: .eightAM,
                eveningTime: .eightPM
            )
        await fetchNotificiations()
    }

    func notificationAmount(for name: String?) -> Int {
        return notificationManager?
            .notifications
            .filter({$0.identifier.contains(name ?? "-")})
            .count ?? 0
    }

    func fetchNotificiations() async {
        await notificationManager?.refreshNotifications()
    }

    private func notificationView(notification: UNNotificationRequest) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Label {
                Text(.notificationTo)
            } icon: {
                if notification.identifier.contains("morning") {
                    Image(systemSymbol: .sunMaxCircleFill)
                        .foregroundStyle(.yellow)
                        .font(.title)
                } else if notification.identifier.contains("evening") {
                    Image(systemSymbol: .moonStarsCircleFill)
                        .foregroundStyle(.blue)
                        .font(.title)
                } else {
                    Image(systemSymbol: .birthdayCakeFill)
                        .foregroundStyle(.green)
                        .font(.title)
                }

            }
            Text(notification.content.body)
                .font(.footnote)
                .foregroundStyle(Color.gray)
            HStack(spacing: 10) {
                Text(.nextNotificationDate)
                    .bold()
                if let trigger = notification.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    if notification.identifier.contains("birthday") {
                        Text(date.formatted(.dateTime.day().month(.wide).year()))
                    } else {
                        Text(date.formatted(.dateTime.hour().minute()))
                    }
                }
            }
        }
    }

    func remove(pet: Pet, at offset: IndexSet) async {
        if let notificationManager {
            for index in offset {
                let notification = notificationManager.filterNotifications(of: pet)[index]
                try? await notificationManager
                    .removeNotificationsIdentifiers(with: [notification.identifier])
            }
        }
    }

    private func notificationSection(for pet: Pet, notificationManager: NotificationManager) -> some View {
        Section {
            if notificationManager.filterNotifications(of: pet).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        Task {
                            await createNotifications(for: pet)
                        }
                    } label: {
                        Text(.createDefaultNotificationsForYourPet)
                    }
                }
            } else {
                ForEach(
                    notificationManager.filterNotifications(of: pet),
                    id: \.identifier
                ) { notification in
                    notificationView(notification: notification)
                }
                .onDelete { indexSet in
                    Task {
                        await remove(pet: pet, at: indexSet)
                    }
                }
            }

        } header: {
            Text(pet.name)
        } footer: {
            let count = notificationAmount(for: pet.name)
            Text(.notification(count))
        }
        .onChange(of: notificationManager.notifications) {
            Task {
                await fetchNotificiations()
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        NotificationView()
    }
    .modelContainer(DataController.previewContainer)
    .environment(NotificationManager.shared)

}
#endif
