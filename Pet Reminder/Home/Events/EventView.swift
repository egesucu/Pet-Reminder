//
//  EventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

struct EventView : View {
    
    var event : EKEvent? = nil
    var startDateInString : String? = ""
    var endDateInString : String? = ""
    var eventVM : EventManager? = nil

    @State private var isShowing = false
    
    var body: some View{
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors:[Color(.systemGreen), Color(.systemTeal)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
            VStack{
                Text(event?.title ?? "")
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
                if ((event?.isAllDay) != nil){
                    Text(startDateInString ?? "")
                        .font(.body)
                        .multilineTextAlignment(.center)
                } else {
                    HStack {
                        Text(startDateInString ?? "")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Text("-")
                        Text(endDateInString ?? "")
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                }
                
            }
            .padding()
        }
        .padding(.bottom, 10)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView()
    }
}
