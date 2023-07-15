//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct NotificationView: View {

    @Environment(\.modelContext)
    private var viewContext

    @Query var pets: [Pet]

    var notificationManager = NotificationManager.shared

    func filteredNotifications(pet: Pet) -> [UNNotificationRequest] {
        notificationManager.notifications.filter({$0.identifier.contains(pet.name)})
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

                            case let option where option.contains(NotificationType.evening.rawValue):
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

                            case let option where option.contains(NotificationType.birthday.rawValue):

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
                                        Text(pet.birthday.formatted(.dateTime.day().month(.wide).year()))
                                        Spacer()
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(Color.green)
                                }
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
                    Text(pet.name)
                } footer: {
                    let count = notificationManager.notifications.filter({$0.identifier.contains(pet.name)}).count
                    Text("notification \(count)")

                }

            }
            .onDelete(perform: remove)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            notificationManager.getNotifications()
        }
        .navigationTitle(Text("notifications_title"))
        .navigationViewStyle(.stack)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    notificationManager
                        .removeNotifications(pets: pets.compactMap({ $0 as Pet }))
                    notificationManager
                        .getNotifications()
                } label: {
                    Text("remove_all")
                }
            }
        }
        .onAppear {
            notificationManager
                .getNotifications()
            notificationManager
                .removeOtherNotifications(beside: pets.compactMap({ $0.name }))
        }
    }

    func createNotifications(for pet: Pet) {
        switch pet.selection {
        case .both:
            notificationManager.createNotification(of: pet.name, with: .morning, date: pet.morningTime ?? .now)
            notificationManager.createNotification(of: pet.name, with: .evening, date: pet.eveningTime ?? .now)
            notificationManager.createNotification(of: pet.name, with: .birthday, date: pet.birthday)
        case .morning:
            notificationManager.createNotification(of: pet.name, with: .morning, date: pet.morningTime ?? .now)
            notificationManager.createNotification(of: pet.name, with: .birthday, date: pet.birthday)
        case .evening:
            notificationManager.createNotification(of: pet.name, with: .evening, date: pet.eveningTime ?? .now)
            notificationManager.createNotification(of: pet.name, with: .birthday, date: pet.birthday)
        }
    }

    func remove(at offset: IndexSet) {
        for index in offset {
            let notification = notificationManager.notifications[index]
            notificationManager
                .removeNotificationsIdentifiers(with: [notification.identifier])
            notificationManager
                .getNotifications()
        }
    }
}

#Preview {
    NotificationView()
}
