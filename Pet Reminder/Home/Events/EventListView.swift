//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct EventListView : View {
    
    @StateObject var eventVM = EventManager()
    @State private var showAddEvent = false
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    let feedback = UINotificationFeedbackGenerator()
    
    var body: some View{
        
        NavigationView{
            ZStack{
                if eventVM.events.isEmpty{
                    EmptyEventView()
                } else {
                    EventsView(eventVM: eventVM)
                }
            }
            .navigationTitle(Text("event_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddEvent.toggle()
                    } label: {
                        Label("add_event_accessible_title", systemImage: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(tintColor)
                    }
                    .sheet(isPresented: $showAddEvent, onDismiss: {
                        eventVM.reloadEvents()
                    }, content: {
                        AddEventView(feedback: feedback)
                    })
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            eventVM.reloadEvents()
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventListView(eventVM: EventManager(isDemo: true))
                .previewDisplayName("Demo")
        }
    }
}
