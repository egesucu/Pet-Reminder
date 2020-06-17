//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    
    @State private var tag : Int? = nil
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .center,spacing: 60) {
                    Spacer()
                    Labels()
                    NavigationLink(destination: SetupNameView(),tag: 1, selection: $tag) {
                        EmptyView()
                    }.navigationBarHidden(true).navigationBarTitle("").navigationBarBackButtonHidden(true)
                    Button("Next") {
                        self.tag = 1
                    }.font(Font.system(size: 35)).foregroundColor(.white).frame(minWidth: 0, maxWidth: .infinity)
                        .padding([.leading, .trailing], 20).background(Color.green).cornerRadius(UIScreen.main.bounds.width / 2).shadow(color: Color.black.opacity(0.6),radius: 4, x:0, y:2)
                    
                 Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()
                
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        HelloView()
    }
}

struct Labels: View {
    
    var body: some View {
        
        VStack(alignment: .center,spacing: 50){
            Image("pet-reminder").resizable().scaledToFit()
            Spacer()
            Text("Welcome-Slogan").padding().font(.largeTitle).minimumScaleFactor(0.8).lineLimit(1)
            Spacer()
            Text("Welcome-Slogan-2").padding().font(.body).lineLimit(nil)
            Spacer()
        }
        
    }
    
}
