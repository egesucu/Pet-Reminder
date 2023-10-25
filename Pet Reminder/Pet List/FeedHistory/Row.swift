//
//  Row.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct Row: View {
    var imageName: String
    var title: String
    var content: String
    var type: NotificationType

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .symbolRenderingMode(.hierarchical)
                .font(.title)
                .foregroundStyle(type == .morning ? .yellow  : .blue)
            Text(content)
        }
    }
}

#Preview {
    Row(
        imageName: "",
        title: "",
        content: "",
        type: .morning
    )
}
