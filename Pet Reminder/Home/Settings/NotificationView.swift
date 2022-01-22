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
                        Text(notification.identifier)
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
                    notificationManager.removeNotifications(pets: pets.reversed())
                    notificationManager.getNotifications()
                } label: {
                    Text("remove_all")
                }
            }
        }
        .onAppear {
            notificationManager.getNotifications()
        }
    }
    
    func remove(at offset: IndexSet){
        for index in offset{
            let notification = notificationManager.notifications[index]
            notificationManager.removeNotificationWithId(notification.identifier)
            notificationManager.getNotifications()
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
