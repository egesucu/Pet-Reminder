//
//  SheetContent.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import EventKit

struct SheetContent: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(Strings.tintColor) var tintColor = Color.green
    
    var event: EKEvent
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ESEventDetailView(event: event)
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: SFSymbols.close)
                    .font(.title)
                    .tint(tintColor)
            })
            .offset(x: -10, y: 10)
            
        }
    }
}
#Preview {
    SheetContent(event: .init(eventStore: .init()))
}
