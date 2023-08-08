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
                    if filteredNotifications(pet: pet).isEmpty {
                        Button("Create default notifications for your pet.",
                               action: { createNotifications(for: pet) })
                    } else {
                        ForEach(filteredNotifications(pet: pet), id: \.self) { notification in
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
                        }
                    }

                } header: {
                    Text(pet.name ?? "-")
                } footer: {
                    let count = notificationManager.notifications.filter({$0.identifier.contains(pet.name ?? "-")}).count
                    Text("notification \(count)")

                }

            }
            .onDelete(perform: remove)
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
                    fetchNotificiations()
                } label: {
                    Text("remove_all")
                }
            }
        }
        .onAppear {
            fetchNotificiations()
            notificationManager
                .removeOtherNotifications(beside: pets.compactMap({ $0.name }))
        }
    }
    
    private func fetchNotificiations() {
        Task {
            await notificationManager.getNotifications()
        }
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
                Text((pet.birthday ?? .now).formatted(.dateTime.day().month(.wide).year()))
                Spacer()
            }
            .font(.footnote)
            .foregroundStyle(Color.green)
        }
    }

    func createNotifications(for pet: Pet) {
        switch pet.selection {
        case .both:
            notificationManager.createNotification(of: pet.name ?? "", with: .morning, date: pet.morningTime ?? .now)
            notificationManager.createNotification(of: pet.name ?? "", with: .evening, date: pet.eveningTime ?? .now)
            notificationManager.createNotification(of: pet.name ?? "", with: .birthday, date: pet.birthday ?? .now)
        case .morning:
            notificationManager.createNotification(of: pet.name ?? "", with: .morning, date: pet.morningTime ?? .now)
            notificationManager.createNotification(of: pet.name ?? "", with: .birthday, date: pet.birthday ?? .now)
        case .evening:
            notificationManager.createNotification(of: pet.name ?? "", with: .evening, date: pet.eveningTime ?? .now)
            notificationManager.createNotification(of: pet.name ?? "", with: .birthday, date: pet.birthday ?? .now)
        }
    }

    func remove(at offset: IndexSet) {
        for index in offset {
            let notification = notificationManager.notifications[index]
            notificationManager
                .removeNotificationsIdentifiers(with: [notification.identifier])
            fetchNotificiations()
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
