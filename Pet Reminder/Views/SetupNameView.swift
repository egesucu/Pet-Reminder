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
    @State private var birthday = Date()
    @State private var showingAlert = false
    @State var selection: Int? = nil
    
    var body: some View {
        
        NavigationView {
            VStack{
                Text("Name")
                    .font(.largeTitle)
                    .padding()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                TextField("Text", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Birthday").font(.largeTitle).padding().lineLimit(1).minimumScaleFactor(0.5)
                DatePicker("Please enter a date", selection: $birthday, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                    .padding()
                    .frame(height: 80)
                    .clipped()
                Spacer()
                NavigationLink(destination: SetupPhotoView(name: self.name, birthday: self.birthday), tag: 1, selection : $selection) {
                    Button("Next"){
                        if self.name.isEmpty {
                            self.selection = 0
                            self.showingAlert = true
                        } else {
                            self.showingAlert = false
                            self.selection = 1
                        }
                        
                    }
                    .font(Font.system(size: 35))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(60)
                    .padding()
                    .alert(isPresented: $showingAlert, content: {
                        Alert(title: Text("Name-Message"))
                    })
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea(.all, edges: .all))
            .navigationBarTitle("Personal Information")
        }
        
    }
}


struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            SetupNameView()
        }
        
        
    }
}

