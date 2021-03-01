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
        VStack {
            Image("pet-reminder")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 600).padding(40).layoutPriority(1)
            Spacer().frame(height:0)
            Text("Welcome-Slogan").padding().font(.subheadline).layoutPriority(1)
            Spacer().frame(height:0)
            Text("Welcome-Slogan-2").padding().font(.body).lineLimit(nil).layoutPriority(1)
            Spacer().frame(height:0)
            Button("Continue") {
                self.showNextView.toggle()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.black.opacity(0.5), radius: 2, x: 2.0, y: 2.0)
            .fullScreenCover(isPresented: $showNextView, content: {
                SetupNameView(comingFromMain: .constant(false))
            })
            
        }
    }
    
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            HelloView()
        
        }
        
    }
}


