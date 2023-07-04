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
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 100).fill(Color.accentColor)
            Text(dateString)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(Color.accentColor.isDarkColor ? .white : .black)
        }
    }
}

// #Preview {
//    MainActor.assumeIsolated {
//        EventTimeView(dateString: .constant(Strings.demo))
//    }
//    
// }

struct EventTimeViewDemo: PreviewProvider {
    static var previews: some View {
        EventTimeView(dateString: .constant(Strings.demo))
            .modelContainer(for: Pet.self)
    }
}
