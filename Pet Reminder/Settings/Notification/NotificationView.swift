//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct NotificationView: View {

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    private var pets: FetchedResults<Pet>

    @State private var notificationManager = NotificationManager()

    func filteredNotifications(pet: Pet) -> [UNNotificationRequest] {
        notificationManager.filterNotifications(of: pet)
    }

    var body: some View {
        List {
            ForEach(pets, id: \.name) { pet in
                Section {
                    if notificationManager.filterNotifications(of: pet).isEmpty {
                        Button("Create default notifications for your pet.",
                               action: { createNotifications(for: pet) })
                    } else {
                        ForEach(notificationManager.filterNotifications(of: pet), id: \.identifier) { notification in
                            switch notification.identifier {
                            case let option where option.contains(NotificationType.morning.rawValue):
                                morningNotificationView(notification: notification)

                            case let option where option.contains(NotificationType.evening.rawValue):
                                eveningNotificationView(notification: notification)

                            case let option where option.contains(NotificationType.birthday.rawValue):
                                birthdayNotificationsView(notification: notification, pet: pet)
                            default:
                                VStack(alignment: .leading) {
                                    Text(notification.identifier)
                                    Text(notification.content.body)
                                        .font(.footnote)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }.onDelete { indexSet in
                            remove(pet: pet, at: indexSet)
                        }
                    }

                } header: {
                    Text(pet.wrappedName)
                } footer: {
                    let count = notificationAmount(for: pet.wrappedName)
                    Text("notification \(count)")

                }

            }
            
        }
        .listStyle(.insetGrouped)
        .refreshable {
            Task {
                await notificationManager.getNotifications()
            }

        }
        .navigationTitle(Text("notifications_title"))
        .navigationViewStyle(.stack)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    notificationManager
                        .removeNotifications(pets: pets.compactMap({ $0 as Pet }))
                    Task {
                        await fetchNotificiations()
                    }
                } label: {
                    Text("remove_all")
                }
            }
        }
        .task(fetchNotificiations)
        .onAppear {
            notificationManager
                .removeOtherNotifications(beside: pets.compactMap({ $0.name }))
        }
    }

    func notificationAmount(for name: String?) -> Int {
        return notificationManager
            .notifications
            .filter({$0.identifier.contains(name ?? "-")})
            .count
    }

    @Sendable func fetchNotificiations() async {
        await notificationManager.getNotifications()
    }

    private func morningNotificationView(notification: UNNotificationRequest) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("notification_to")
            } icon: {
                Image(systemName: SFSymbols.morning)
                    .foregroundColor(.yellow)
                    .font(.title)
            }
            Text(notification.content.body)
                .font(.footnote)
                .foregroundStyle(Color.gray)
        }
    }

    private func eveningNotificationView(notification: UNNotificationRequest) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("notification_to")
            } icon: {
                Image(systemName: SFSymbols.evening)
                    .foregroundColor(.blue)
                    .font(.title)
            }
            Text(notification.content.body)
                .font(.footnote)
                .foregroundStyle(Color.gray)
        }
    }

    private func birthdayNotificationsView(notification: UNNotificationRequest, pet: Pet) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("notification_to")
            } icon: {
                Image(systemName: SFSymbols.birthday)
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(Color.green.gradient, Color.blue.gradient)
                    .font(.title)
            }
            Text(notification.content.body)
                .font(.footnote)
                .foregroundStyle(Color.gray)
            HStack {
                Text("birthday_title")
                Text((pet.wrappedBirthday).formatted(.dateTime.day().month(.wide).year()))
                Spacer()
            }
            .font(.footnote)
            .foregroundStyle(Color.green)
        }
    }

    func createNotifications(for pet: Pet) {
        switch pet.selection {
        case .both:
            notificationManager.createNotification(of: pet.wrappedName, with: .morning, date: pet.morningTime ?? .now)
            notificationManager.createNotification(of: pet.wrappedName, with: .evening, date: pet.eveningTime ?? .now)
            notificationManager.createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        case .morning:
            notificationManager.createNotification(of: pet.wrappedName, with: .morning, date: pet.morningTime ?? .now)
            notificationManager.createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        case .evening:
            notificationManager.createNotification(of: pet.wrappedName, with: .evening, date: pet.eveningTime ?? .now)
            notificationManager.createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        }
        
        Task {
            await fetchNotificiations()
        }
        
    }

    func remove(pet: Pet, at offset: IndexSet) {
        
        for index in offset {
            let notification = notificationManager.filterNotifications(of: pet)[index]
            print(notification.identifier)
            notificationManager
                .removeNotificationsIdentifiers(with: [notification.identifier])
        }
    }
}

#Preview {
    NotificationView()
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}
