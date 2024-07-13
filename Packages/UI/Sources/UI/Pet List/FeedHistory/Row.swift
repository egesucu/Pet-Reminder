//
//  Row.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

public struct Row: View {
    public var imageName: String
    public var title: String
    public var content: String
    public var type: NotificationType

    public var body: some View {
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
