//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    
    var body: some View {
        VStack {
            LabelView()
            
        }
    }
    
}

struct LabelView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    @State private var showNextView = false
    
    var body: some View {
        Group{
            
            if sizeClass == .compact {
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
                    SetupNameView()
                })
            } else if sizeClass == .regular {
                Image("pet-reminder").resizable().scaledToFit().frame(maxWidth: 1500).padding(40).layoutPriority(1)
                Spacer()
                Text("Welcome-Slogan").padding().font(.custom("System", size: 60, relativeTo: .largeTitle)).layoutPriority(1)
                Spacer()
                Text("Welcome-Slogan-2")
                    .padding()
                    .font(.custom("System", size: 40, relativeTo: .body)).layoutPriority(1)
                Spacer()
                Button("Continue") {
                    self.showNextView.toggle()
                }
                
                .frame(width: 500, height: 200, alignment: .center)
                .font(.custom("System", size: 40, relativeTo: .headline))
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color("ShadowColor"), radius: 10, x: 4.0, y: 4.0)
                .fullScreenCover(isPresented: $showNextView, content: {
                    SetupNameView()
                })
                .padding(.bottom,50)
                
            }
        }
        
        
        
        
    }
    
}


struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            HelloView()
//            HelloView().previewLayout(.fixed(width: 2732, height: 2048))
//            HelloView().previewLayout(.fixed(width: 2048, height: 2732))
        
        }
        
        
    }
}


