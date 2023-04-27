//
//  EventTimeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct EventTimeView: View {
    
    @Binding var dateString: String
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 100).fill(tintColor)
            Text(dateString)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(tintColor.isDarkColor ? .white : .black)
        }
    }
}

struct EventTimeView_Previews: PreviewProvider {
    static var previews: some View {
        EventTimeView(dateString: .constant("Demo"))
    }
}
