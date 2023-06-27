//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct NotificationView: View {

    @Environment(\.modelContext)
    private var viewContext

    @Query var pets: [Pet]

    @ObservedObject var notificationManager = NotificationManager.shared

    func filteredNotifications(pet: Pet) -> [UNNotificationRequest] {
        notificationManager.notifications.filter({$0.identifier.contains(pet.name ?? "")})
    }

    var body: some View {
        List {
            ForEach(pets, id: \.id) { pet in
                Section {
                    ForEach(filteredNotifications(pet: pet), id: \.self) { notification in
                        switch notification.identifier {
                        case let option where option.contains(NotificationType.morning.rawValue):
                            Label {
                                Text("notification_to")
                            } icon: {
                                Image(systemName: SFSymbols.morning)
                                    .foregroundColor(.yellow)
                                    .font(.title)
                            }
                        case let option where option.contains(NotificationType.evening.rawValue):
                            Label {
                                Text("notification_to")
                            } icon: {
                                Image(systemName: SFSymbols.evening)
                                    .foregroundColor(.blue)
                                    .font(.title)
                            }
                        case let option where option.contains(NotificationType.birthday.rawValue):
                            Label {
                                Text("notification_to")
                            } icon: {
                                Image(systemName: SFSymbols.birthday)
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(Color.green.gradient, Color.blue.gradient)
                                    .font(.title)
                            }
                        default:
                            Text(notification.identifier)

                        }
                    }
                } header: {
                    Text(pet.name ?? "")
                } footer: {
                    let count = notificationManager.notifications.filter({$0.identifier.contains(pet.name ?? "")}).count
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
                    notificationManager.removeNotifications(pets: pets.compactMap({ $0 as Pet }))
                    notificationManager.getNotifications()
                } label: {
                    Text("remove_all")
                }
            }
        }
        .onAppear {
            notificationManager.getNotifications()
            notificationManager.removeOtherNotifications(beside: pets.compactMap({ $0.name ?? "" }))
        }
    }

    func remove(at offset: IndexSet) {
        for index in offset {
            let notification = notificationManager.notifications[index]
            notificationManager.removeNotificationsIdentifiers(with: [notification.identifier])
            notificationManager.getNotifications()
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
