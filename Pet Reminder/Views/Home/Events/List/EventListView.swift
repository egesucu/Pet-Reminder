//
//  EventListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct EventListView : View {
    
    @StateObject var eventVM = EventManager()
    @State private var showAddEvent = false
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen
    
    var body: some View{
        
        NavigationView{
            showEventView()
                .navigationTitle(Text(Strings.eventTitle))
                .toolbar(content: eventToolBar)
            
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: reloadEvents)
    }
    
    @ToolbarContentBuilder
    func eventToolBar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: toggleAddEvent) {
                Label(Strings.addEventAccessibleTitle, systemImage: SFSymbols.calendar)
                    .font(.title2)
                    .foregroundColor(tintColor)
            }
            .sheet(isPresented: $showAddEvent, onDismiss: reloadEvents, content: { AddEventView() })
        }
    }
    
    private func reloadEvents() {
        Task {
            await eventVM.reloadEvents()
        }
    }
    
    private func toggleAddEvent() {
        showAddEvent.toggle()
    }
    
    @ViewBuilder
    func showEventView() -> some View {
        if eventVM.events.isEmpty{
            EmptyEventView(eventVM: eventVM)
        } else {
            EventsView(eventVM: eventVM)
        }
    }
    
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventListView(eventVM: EventManager(isDemo: true))
                .previewDisplayName(Strings.demo)
        }
    }
}