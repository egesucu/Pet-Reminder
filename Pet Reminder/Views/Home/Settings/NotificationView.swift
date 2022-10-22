//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 22.01.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    private var pets : FetchedResults<Pet>
    
    @ObservedObject var notificationManager = NotificationManager.shared
    
    
    var body: some View {
        List{
            ForEach(pets, id: \.name) { pet in
                Section {
                    ForEach(notificationManager.notifications.filter({$0.identifier.contains(pet.name ?? "")}),id: \.self){ notification in
                        if notification.identifier.contains("morning"){
                            Label {
                                Text("notification_to")
                            } icon: {
                                Image(systemName: "sun.max.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundColor(.yellow)
                                    .font(.title)
                            }
                        } else if notification.identifier.contains("evening"){
                            Label {
                                Text("notification_to")
                            } icon: {
                                Image(systemName: "moon.stars.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundColor(.yellow)
                                    .font(.title)
                            }
                        } else if notification.identifier.contains("birthday"){
                            Label {
                                Text("notification_to")
                            } icon: {
                                if #available(iOS 16.0, *) {
                                    Image(systemName: "birthday.cake.fill")
                                        .symbolRenderingMode(.multicolor)
                                        .foregroundStyle(Color.green.gradient, Color.blue.gradient)
                                        .font(.title)
                                } else {
                                    Image(systemName: "birthday.cake.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundColor(.green)
                                        .font(.title)
                                }
                            }
                        } else {
                            Text(notification.identifier)
                        }
                    }
                } header: {
                    Text(pet.name ?? "")
                } footer: {
                    let count = notificationManager.notifications.filter({$0.identifier.contains(pet.name ?? "")}).count
                    if count == 1 {
                        Text("notification \(count)")
                    } else {
                        Text("notifications \(count)")
                    }
                    
                }

                
            }.onDelete(perform: remove)
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
            notificationManager.removeOtherNotifications(beside: pets.compactMap({ $0.name }))
        }
    }
    
    func remove(at offset: IndexSet){
        for index in offset{
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
