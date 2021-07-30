//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI



struct MainView: View {
    
    let petCount = UserDefaults.standard.integer(forKey: "petCount")
    
    var body: some View{
        
        VStack{
            if petCount > 0 {
                HomeView()
            } else {
                HelloView()
            }
        }
        
    }

}

struct HelloView: View {
    
    @State private var showSetup = false
    
    var body: some View {
        VStack(alignment: .center) {
            Image("pet-reminder")
                .resizable()
                .scaledToFit()
                .padding([.top,.bottom])
            Text("Welcome-Slogan")
                .padding([.top,.bottom])
                .font(.title)
            Spacer()
            Text("Welcome-Slogan-2")
                .padding([.top,.bottom])
                .font(.body)
            Spacer()
            Button {
                self.showSetup.toggle()
            } label: {
                
                Label("Add Pet", systemImage: "plus.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
            }
            .padding()
            .background(Capsule().fill(Color(uiColor: .systemGreen)))
            .shadow(radius: 10)
            .sheet(isPresented: $showSetup) {
                // some reload method to get petCount, ondismiss
            } content: {
                SetupNameView()
            }

        }.padding()
    }
    
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
           MainView()
        }
        
    }
}


