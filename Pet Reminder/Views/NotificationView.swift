//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 14.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    
    @State private var date = Date()
    @State private var text = "Morning"
    
    
    var body: some View {
        VStack {
            DatePicker(selection: $date, in: ...Date(), displayedComponents: .hourAndMinute) {
                Text(text).font(.body).fontWeight(.regular)
            }
        }.padding()
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            
            
    }
}
