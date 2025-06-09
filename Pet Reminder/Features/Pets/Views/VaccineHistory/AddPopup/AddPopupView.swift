//
//  AddPopupView.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct AddPopupView: View {

    @Binding var contentInput: String
    @Binding var dateInput: Date
    var onSave: () -> Void
    var onCancel: () -> Void
    

    var body: some View {
        ZStack {
            Color(uiColor: .label)
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
                .tint(.accent)
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

struct PopupWrapper<PresentingView: View, Content: View>: View {

    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: Content

    var body: some View {
        ZStack {
            if isPresented { content }
            presentingView
        }
    }
}

extension View {
    
    func wiggling() -> some View {
        modifier(WiggleModifier())
    }
    
    func popupView(isPresented: Binding<Bool>,
                   content: AddPopupView) -> some View {
        PopupWrapper(isPresented: isPresented,
                     presentingView: self,
                     content: content)
    }
}
