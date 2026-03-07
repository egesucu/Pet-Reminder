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
        HStack(alignment: .center, spacing: PRSpacing.spacing8) {
            Image(systemName: imageName)
                .font(.system(size: PRIconSize.icon24))
            Text(content)
        }
        .bold()
        .foregroundStyle(.white)
        .padding(PRSpacing.spacing16)
        .glassEffect(
            .regular.tint(
                type == .morning ? .yellow  : .blue
            )
        )
    }
}

#if DEBUG
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
#endif
