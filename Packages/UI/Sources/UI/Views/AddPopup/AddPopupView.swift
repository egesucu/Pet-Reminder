//
//  AddPopupView.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

public struct AddPopupView: View {

    @Binding var contentInput: String
    @Binding var dateInput: Date
    var onSave: () -> Void
    var onCancel: () -> Void
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    public var body: some View {
        ZStack {
            ESColor.label
                .opacity(0.8)
                .onTapGesture(perform: onCancel)
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .systemBackground))
                VStack(alignment: .center) {
                    HStack {
                        Text("add")
                            .bold()
                        TextField(Strings.placeholderVaccine, text: $contentInput)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                    DatePicker(selection: $dateInput) {
                        Text("date")
                            .bold()
                    }.padding(.horizontal)

                    HStack {
                        Button(action: onCancel) {
                            Text("cancel")
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button(action: onSave) {
                            Text("add")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.all)
                }
                .tint(tintColor.color)
            }
        .frame(width: 300, height: 200)
        }
        .zIndex(2)
        .ignoresSafeArea()
    }

}

#Preview {
    AddPopupView(contentInput: .constant(""), dateInput: .constant(.now), onSave: { }, onCancel: { })
        .ignoresSafeArea()
        .padding(.all)
}

public struct PopupWrapper<PresentingView: View, Content: View>: View {

    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: Content

    public var body: some View {
        ZStack {
            if isPresented { content }
            presentingView
        }
    }
}
