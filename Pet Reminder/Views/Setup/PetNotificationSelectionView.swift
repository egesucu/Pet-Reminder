//
//  PetNotificationSelectionView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetNotificationSelectionView: View {
    
    @Binding var dayType: DayTime
    @Binding var morningFeed: Date
    @Binding var eveningFeed: Date
    
    var body: some View {
        VStack {
            Text("feed_time_title")
                .font(.title2).bold()
                .padding([.top,.bottom])
            Picker(selection: $dayType, label: Text("feed_time_title")) {
                Text("feed_selection_both")
                    .tag(DayTime.both)
                Text("feed_selection_morning")
                    .tag(DayTime.morning)
                Text("feed_selection_evening")
                    .tag(DayTime.evening)
            }
            .pickerStyle(SegmentedPickerStyle())
            .animation(.easeOut(duration: 0.8), value: dayType)
            
            NotificationType()
                .animation(.easeOut(duration: 0.8), value: dayType)
                .padding(.all)
        }
        
    }
    
    @ViewBuilder func NotificationType() -> some View {
        switch dayType {
        case .morning:
            MorningView
        case .evening:
            EveningView
        default:
            BothView
        }
    }
    
    var MorningView: some View {
        HStack {
            Image("morning")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_morning",
                       selection: $morningFeed,
                       in: ...eveningFeed.addingTimeInterval(60),
                       displayedComponents: .hourAndMinute)
            
        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)
        
    }
    
    var EveningView: some View{
        HStack{
            Image("evening")
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_evening",
                       selection: $eveningFeed,
                       in: morningFeed.addingTimeInterval(60)...,
                       displayedComponents: .hourAndMinute)
        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)
    }
    
    var BothView: some View {
        VStack {
            MorningView
                .padding([.top,.bottom])
            EveningView
        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)
    }
}

struct PetNotificationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PetNotificationSelectionView(dayType: .constant(.both), morningFeed: .constant(.now), eveningFeed: .constant(.now))
    }
}
