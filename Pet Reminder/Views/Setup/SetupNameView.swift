//
//  SetupNameView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupNameView: View {
    
    @State private var name = ""
    @State private var petSaved = false
    
    var petManager = PetManager()
    
    var body: some View {
        
        NavigationView {
            VStack{
                Text("Name")
                    .font(.title).bold()
                TextField("Text", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 8)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom])
            }
            .padding()
            .navigationBarTitle("Setup")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Continue") {
                        SetupBirthdayView(petManager: petManager)
                    }
                    .foregroundColor(name.isEmpty ? .gray : .green)
                    .font(.body.bold())
                    .disabled(name.isEmpty)
                    .onTapGesture {
                        petManager.getName(name: name)
                    }
                }
            }
            
        }
        .navigationViewStyle(.stack)
    }
    
}

struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNameView(petManager: PetManager())
    }
}
