//
//  EveningNotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct EveningNotificationView: View {
    
    @Binding var eveningTime : Date
    
    var body: some View {
        Text("Let's choose an evening notification")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding([.top,.bottom],10)
        
        DatePicker("Choose a time", selection: $eveningTime, displayedComponents: .hourAndMinute)
            .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
            .padding([.top,.bottom],10)
        Spacer()
    }
}
