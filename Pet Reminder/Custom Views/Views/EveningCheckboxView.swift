//
//  EveningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct EveningCheckboxView : View {
    
    @Binding var eveningOn : Bool
    
    var body: some View{
        VStack{
            Label {
                Text("feed_selection_evening")
                    .foregroundColor(Color(uiColor: .label))
                    .font(.title2.bold())
            } icon: {
                Image(systemName: eveningOn ? "moon.fill" : "moon")
                    .foregroundColor(.blue)
                    .font(.largeTitle.bold())
            }
            .padding(.bottom)
            withAnimation {
                Image(systemName: eveningOn ? "checkmark.square" : "square")
                    .font(.system(size: 50))
                    .animation(.easeInOut, value: eveningOn)
            }
        }
        .cornerRadius(20)
        .frame(width:150,height:150)
        
    }
}

struct EveningView_Previews: PreviewProvider {
    static var previews: some View {
        EveningCheckboxView(eveningOn: .constant(true))
    }
}