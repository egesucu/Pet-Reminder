//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import SharedModels

public struct NotificationView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Pet.name) var pets: [Pet]

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    public var body: some View {
        VStack {
            List {
                ForEach(pets, id: \.name) { pet in
                    if let notificationManager {
                        Section {
                            if notificationManager.filterNotifications(of: pet).isEmpty {
                                Button {
                                    Task {
                                        await notificationManager
                                            .createNotifications(
                                                for: pet,
                                                morningTime: .eightAM,
                                                eveningTime: .eightPM
                                            )
                                        await fetchNotificiations()
                                    }
                                } label: {
                                    Text("Create default notifications for your pet.", bundle: .module)
                                }
                            } else {
                                ForEach(
                                    notificationManager.filterNotifications(of: pet),
                                    id: \.identifier
                                ) { notification in
                                    notificationView(notification: notification)
                                }.onDelete { indexSet in
                                    remove(pet: pet, at: indexSet)
                                }
                            }

                        } header: {
                            Text(pet.name)
                        } footer: {
                            let count = notificationAmount(for: pet.name)
                            Text("notification \(count)", bundle: .module)

                        }
                        .onChange(of: notificationManager.notifications) {
                            Task {
                                await fetchNotificiations()
                            }
                        }
                    }
                }

            }
            .listStyle(.insetGrouped)
            .refreshable {
                await notificationManager?.getNotifications()
            }
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView("pet_no_pet", systemImage: "pawprint.circle")
            }
        }
        .navigationTitle(Text("notifications_title", bundle: .module))
        .navigationViewStyle(.stack)
        .toolbar {
            if pets.isNotEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        notificationManager?.notificationCenter.removeAllPendingNotificationRequests()
                        notificationManager?.notifications.removeAll()
                        Task {
                            await fetchNotificiations()
                        }
                    } label: {
                        Text("remove_all", bundle: .module)
                    }
                }

            }
        }
        .task {
            await notificationManager?.getNotifications()
        }
    }

    func notificationAmount(for name: String?) -> Int {
        return notificationManager?
            .notifications
            .filter({$0.identifier.contains(name ?? "-")})
            .count ?? 0
    }

    func fetchNotificiations() async {
        await notificationManager?.getNotifications()
    }

    private func notificationView(notification: UNNotificationRequest) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("notification_to", bundle: .module)
            } icon: {
                if notification.identifier.contains("morning") {
                    Image(systemName: SFSymbols.morning)
                        .foregroundStyle(.yellow)
                        .font(.title)
                } else if notification.identifier.contains("evening") {
                    Image(systemName: SFSymbols.evening)
                        .foregroundStyle(.blue)
                        .font(.title)
                } else {
                    Image(systemName: SFSymbols.birthday)
                        .foregroundStyle(.green)
                        .font(.title)
                }

            }
            Text(notification.content.body)
                .font(.footnote)
                .foregroundStyle(Color.gray)
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

    func remove(pet: Pet, at offset: IndexSet) {
        if let notificationManager {
            for index in offset {
                let notification = notificationManager.filterNotifications(of: pet)[index]
                notificationManager
                    .removeNotificationsIdentifiers(with: [notification.identifier])
            }
        }
    }
}

#Preview {
    NotificationView()
        .modelContainer(DataController.previewContainer)
        .environment(NotificationManager())
}
