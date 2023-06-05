//
//  AddPopupView.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 25.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct AddPopupView: View {
    
    @Binding var contentInput: String
    @Binding var dateInput: Date
    var onSave: () -> ()
    var onCancel: () -> ()
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.8)
                .onTapGesture(perform: onCancel)
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                VStack(alignment: .center) {
                    HStack {
                        Text(Strings.add)
                            .bold()
                        TextField(Strings.placeholderVaccine, text: $contentInput)
                            .multilineTextAlignment(.center)
                    }
                    .padding([.leading, .trailing])
                    .padding(.bottom, 10)
                    
                    DatePicker(selection: $dateInput) {
                        Text(Strings.date)
                            .bold()
                    }.padding([.leading, .trailing])
                    
                    HStack {
                        Button(action: onCancel) {
                            Text(Strings.cancel)
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button(action: onSave) {
                            Text(Strings.add)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.all)
                }
                .tint(tintColor)
            }
        .frame(width: 300, height: 200)
        }
        .zIndex(2)
        .ignoresSafeArea()
    }
    
    
    
}

struct AddPopupView_Previews: PreviewProvider {
    static var previews: some View {
        AddPopupView(contentInput: .constant(""), dateInput: .constant(.now), onSave: { }, onCancel: { })
        .ignoresSafeArea()
        .padding(.all)
    }
}

struct PopupWrapper<PresentingView: View>: View {
    
    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: () -> AddPopupView
    
    var body: some View {
        ZStack {
            if (isPresented) { content() }
            presentingView
        }
    }
}


extension View {
  func popupView(isPresented: Binding<Bool>,
                      content: @escaping () -> AddPopupView) -> some View {
    PopupWrapper(isPresented: isPresented,
                     presentingView: self,
                     content: content)
  }
}