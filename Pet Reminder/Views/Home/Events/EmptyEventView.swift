//
//  EmptyEventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct EmptyEventView: View {
    
    @ObservedObject var eventVM : EventManager
    
    var body: some View {
        HStack {
            Spacer()
            Text("event_no_title")
                .font(.headline)
                .padding()
                .onTapGesture {
                    eventVM.reloadEvents()
                }
            Spacer()
        }
    }
}

struct EmptyEventView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyEventView(eventVM: .init(isDemo: true))
    }
}
