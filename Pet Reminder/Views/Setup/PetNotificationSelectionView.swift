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
            Text(Strings.feedTimeTitle)
                .font(.title2).bold()
                .padding([.top,.bottom])
            Picker(selection: $dayType, label: Text(Strings.feedTimeTitle)) {
                Text(Strings.feedSelectionBoth)
                    .tag(DayTime.both)
                Text(Strings.feedSelectionMorning)
                    .tag(DayTime.morning)
                Text(Strings.feedSelectionEvening)
                    .tag(DayTime.evening)
            }
            .pickerStyle(.segmented)
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
            Assets.morning.swiftUIImage
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker(Strings.feedSelectionMorning,
                       selection: $morningFeed,
                       in: ...eveningFeed.addingTimeInterval(60),
                       displayedComponents: .hourAndMinute)
            
        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)
        
    }
    
    var EveningView: some View{
        HStack{
            Assets.evening.swiftUIImage
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker(Strings.feedSelectionEvening,
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
