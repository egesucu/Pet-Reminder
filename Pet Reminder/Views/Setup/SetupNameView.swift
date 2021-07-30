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
    @State private var textWritten = false
    
    var petManager = PetManager.shared
    
    var body: some View {
        
        NavigationView {
            VStack{
                Text("Name")
                    .font(.title).bold()
                
                TextField("Text", text: $name, onCommit: {
                    petManager.getName(name: name)
                    textWritten.toggle()
                    print("Name is: \(name)")
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .shadow(radius: 8)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom])
                    
            }
            .padding()
            .navigationBarTitle("Setup")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: SetupBirthdayView(petManager: petManager),
                        label: {
                            Text("Continue")
                        })
                    .foregroundColor(!textWritten ? .gray : .green)
                    .font(.body.bold())
                    .disabled(!textWritten)
                }
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNameView(petManager: PetManager.shared)
    }
}
