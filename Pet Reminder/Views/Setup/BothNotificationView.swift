//
//  BothNotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct BothNotificationView: View {
    
    @Binding var morningTime : Date
    @Binding var eveningTime : Date
    
    var body: some View {
        Text("First, choose a morning notification")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding([.top,.bottom],10)
        
        DatePicker("Choose a time", selection: $morningTime, displayedComponents: .hourAndMinute)
            .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
        Spacer()
        Text("Now, let's choose an evening notification")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding([.top,.bottom],10)
        
        DatePicker("Choose a time", selection: $eveningTime, displayedComponents: .hourAndMinute)
            .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
            .padding([.top,.bottom],10)
        Spacer()
    }
}

