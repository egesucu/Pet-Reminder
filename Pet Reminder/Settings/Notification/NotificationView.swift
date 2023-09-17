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

    var body: some View {
        VStack {
            if pets.isEmpty {
                EmptyPageView(emptyPageReference: .petList)
            } else {
                List {
                    ForEach(pets, id: \.name) { pet in
                        Section {
                            if notificationManager.filterNotifications(of: pet).isEmpty {
                                Button {
                                    Task {
                                        await notificationManager
                                            .createNotifications(for: pet)
                                        await fetchNotificiations()
                                    }
                                } label: {
                                    Text("Create default notifications for your pet.")
                                }
                            } else {
                                ForEach(notificationManager.filterNotifications(of: pet), id: \.identifier) { notification in
                                    notificationView(notification: notification)
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
                        
                        .onChange(of: notificationManager.notifications) {
                            Task {
                                await fetchNotificiations()
                            }
                        }
                        
                    }
                    
                }
                .listStyle(.insetGrouped)
                .refreshable(action: notificationManager.getNotifications)
            }
        }
        .navigationTitle(Text("notifications_title"))
        .navigationViewStyle(.stack)
        .toolbar {
            if pets.isNotEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        notificationManager.notificationCenter.removeAllPendingNotificationRequests()
                        notificationManager.notifications.removeAll()
                        Task {
                            await fetchNotificiations()
                        }
                    } label: {
                        Text("remove_all")
                    }
                }

            }
        }
        .task(fetchNotificiations)
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

    private func notificationView(notification: UNNotificationRequest) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("notification_to")
            } icon: {
                if notification.identifier.contains("morning") {
                    Image(systemName: SFSymbols.morning)
                        .foregroundColor(.yellow)
                        .font(.title)
                } else if notification.identifier.contains("evening") {
                    Image(systemName: SFSymbols.evening)
                        .foregroundColor(.blue)
                        .font(.title)
                } else {
                    Image(systemName: SFSymbols.birthday)
                        .foregroundColor(.green)
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
