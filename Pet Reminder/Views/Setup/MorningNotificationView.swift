//
//  MorningNotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct MorningNotificationView: View {
    
    @Binding var morningTime : Date
    
    
    var body: some View {
        Text("Let's choose a morning notification")
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .padding([.top,.bottom],10)
        
        DatePicker("Choose a time", selection: $morningTime, displayedComponents: .hourAndMinute)
            .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
        Spacer()
    }
}
