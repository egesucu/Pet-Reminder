//
//  Notification.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import Shared

struct Notifications: View {

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Pet.name) var pets: [Pet]

    @Environment(\.notification) private var notificationManager: NotificationManager

    var body: some View {
        VStack(spacing: .zero) {
            List {
                ForEach(pets, id: \.name) { pet in
                    notificationSection(for: pet, notificationManager: notificationManager)
                }
            }
            .listStyle(.insetGrouped)
            .refreshable(action: notificationManager.refreshNotifications)
        }
        .overlay(content: noPets)
        .navigationTitle(Text(.notificationsTitle))
        .toolbar(content: removePets)
        .task(notificationManager.refreshNotifications)
    }

}

// MARK: - Helper UI
private extension Notifications {
    
    @ContentBuilder
    func noPets() -> some View {
        if pets.isEmpty {
            ContentUnavailableView(
                "pet_no_pet",
                systemImage: "pawprint.circle"
            )
        }
    }
    
    @ContentBuilder
    func removePets() -> some ToolbarContent {
        if pets.isNotEmpty {
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    Task {
                        try? await notificationManager.removeNotificationsIdentifiers(
                            with: notificationManager.notifications.map { $0.identifier }
                        )
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
    
    func notificationView(notification: UNNotificationRequest) -> some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Label {
                Text(.notificationTo)
            } icon: {
                if notification.identifier.contains("morning") {
                    Image(systemName: "sun.max.circle.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: .icon24))
                } else if notification.identifier.contains("evening") {
                    Image(systemName: "moon.stars.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.system(size: .icon24))
                } else {
                    Image(systemName: "birthday.cake.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: .icon24))
                }

            }
            Text(notification.content.body)
                .font(.footnote)
                .foregroundStyle(Color.gray)
            HStack(spacing: .spacing8) {
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
    
    func notificationSection(
        for pet: Pet,
        notificationManager: NotificationManager
    ) -> some View {
        Section {
            if notificationManager.filterNotifications(of: pet).isEmpty {
                VStack(alignment: .leading, spacing: .spacing8) {
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
        .onChange(of: notificationManager.notifications, action: fetchNotificiations)
    }
}

// MARK: - Helper functions
private extension Notifications {
    
    func notificationAmount(for name: String?) -> Int {
        notificationManager
            .notifications
            .filter({$0.identifier.contains(name ?? "-")})
            .count
    }
    
    func fetchNotificiations() async {
        await notificationManager.refreshNotifications()
    }
    
    func createNotifications(for pet: Pet) async {
        await notificationManager.createNotifications(
            for: pet,
            morningTime: .eightAM,
            eveningTime: .eightPM
        )
        await fetchNotificiations()
    }
    
    func remove(pet: Pet, at offset: IndexSet) async {
        for index in offset {
            let notification = notificationManager.filterNotifications(of: pet)[index]
            try? await notificationManager
                .removeNotificationsIdentifiers(with: [notification.identifier])
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Notifications()
    }
    .modelContainer(DataController.previewContainer)
    .notification(NotificationManager.shared)

}
#endif
