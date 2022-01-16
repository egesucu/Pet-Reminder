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
    @FocusState private var nameIsFocused: Bool
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    var petManager = PetManager.shared
    
    var body: some View {
        
        NavigationView {
            VStack{
                Text("setup_name")
                    .font(.title).bold()
                
                TextField("Bessie", text: $name, onCommit: {
                    petManager.name = name
                    textWritten.toggle()
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .shadow(radius: 8)
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom])
                    .focused($nameIsFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard){
                            Button("Done") {
                                nameIsFocused = false
                                if !name.isEmpty{
                                    textWritten.toggle()
                                }
                                petManager.name = name
                            }
                            Spacer()
                        }
                    }
            }
            .padding()
            .navigationBarTitle("setup_title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: SetupBirthdayView(petManager: petManager),
                        label: {
                            Text("continue")
                        })
                    .foregroundColor(!textWritten ? .gray : tintColor)
                    .font(.body.bold())
                    .disabled(!textWritten)
                }
            }
            
        }
        .accentColor(tintColor)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNameView(petManager: PetManager.shared)
    }
}
