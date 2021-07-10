//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    
    @State private var showNextView = false
    
    var body: some View {
        VStack(alignment: .center) {
            Image("pet-reminder")
                .resizable()
                .scaledToFit()
                .padding([.top,.bottom],20)
            Text("Welcome-Slogan")
                .padding([.top,.bottom],20)
                .font(.title)
            Spacer()
            Text("Welcome-Slogan-2")
                .padding([.top,.bottom],20)
                .font(.body)
            Spacer()
            Button("Continue") {
                self.showNextView.toggle()
            }
            .padding()
            .font(.largeTitle)
            .background(.green)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(color: .black, radius: 8, x: 4, y: 4)
            
            .fullScreenCover(isPresented: $showNextView, onDismiss: nil, content: {
                SetupNameView()
            })
            
            
            
        }.padding()
    }
    
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            HelloView()
                .preferredColorScheme(.dark)
            
            
        }
        
    }
}


