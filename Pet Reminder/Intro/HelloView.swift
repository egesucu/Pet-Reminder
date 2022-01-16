//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var pets : FetchedResults<Pet>
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    let manager = DataManager.shared
    
    @State private var showSetup = false
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var petsAvailable = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image("pet-reminder")
                    .resizable()
                    .scaledToFit()
                    .padding([.top,.bottom])
                Text("welcome_title")
                    .padding([.top,.bottom])
                    .font(.title)
                Spacer()
                Text("welcome_context")
                    .padding([.top,.bottom])
                    .font(.body)
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        self.showSetup.toggle()
                    } label: {
                        Text("welcome_add_pet")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(tintColor)
                    .cornerRadius(5)
                    .shadow(radius: 3)
                    .sheet(isPresented: $showSetup, content: { SetupNameView()})
                    
                    Spacer()
                    
                }
                
            }.padding()
        }
        .onAppear {
            context.refreshAllObjects()
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


