//
//  Row.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct Row: View {
    var imageName: String
    var content: String
    var type: NotificationType

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.title)
            Text(content)
        }
        .bold()
        .foregroundStyle(.white)
        .padding(.all)
        .glassEffect(
            .regular.tint(
                type == .morning ? .yellow  : .blue
            )
        )
    }
}

#Preview {
    Group {
        Row(
            imageName: "sun.max.circle.fill",
            content: "heyoooooooooooo",
            type: .morning
        )
        Row(
            imageName: "moon.circle.fill",
            content: "Hellooooo",
            type: .evening
        )
    }
}
