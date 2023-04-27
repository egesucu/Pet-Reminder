//
//  EventTitleView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct EventTitleView: View {
    
    @Binding var eventTitle: String
    
    var body: some View {
        Text(eventTitle)
            .font(.headline)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct EventTitleView_Previews: PreviewProvider {
    static var previews: some View {
        EventTitleView(eventTitle: .constant(""))
    }
}
