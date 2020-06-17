//
//  SetupNameView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupNameView: View {
    
    @EnvironmentObject var pet : PetModel
    @State private var birthday = Date()
    @State private var name = ""
    
    @State private var tag:Int? = nil
    @State private var showingAlert = false
    
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        
        ScrollView{
            VStack(alignment: .center, spacing: 10){
                Spacer().navigationBarTitle("Setup").navigationBarBackButtonHidden(true).navigationViewStyle(StackNavigationViewStyle())
                Group{
                    Text("Name")
                        .font(.largeTitle).padding().lineLimit(1).minimumScaleFactor(0.5)
                    TextField("Text", text: $name).textFieldStyle(RoundedBorderTextFieldStyle()).padding().shadow(color: Color(.label).opacity(0.6),radius: 4, x:0, y:2).multilineTextAlignment(.center)
                    
                }
                Spacer()
                Group{
                    Text("Birthday").font(.largeTitle).padding().lineLimit(1).minimumScaleFactor(0.5)
                    Spacer()
                    DatePicker("Please enter a date", selection: $birthday, displayedComponents: .date).labelsHidden().environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr")).padding().shadow(color: Color(.label).opacity(0.6),radius: 4, x:0, y:2).frame(height: 80).clipped()
                    
                }
                Spacer()
                Group {
                    NavigationLink(destination: SetupPhotoView(), tag: 1, selection: $tag) {
                        EmptyView()
                    }
                    
                    
                    Button("Next") {
                        if (self.name.isEmpty){
                            self.generator.notificationOccurred(.error)
                            self.showingAlert = true
                        } else {
                            self.generator.notificationOccurred(.success)
                            self.savePet()
                        }
                    }.font(Font.system(size: 35))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(20)
                        .shadow(color: Color(.label).opacity(0.6),radius: 4, x:0, y:2)
                        .alert(isPresented: $showingAlert) { () -> Alert in
                            Alert(title: Text("Name-Message"))
                            
                    }
                    
                }
                
            }.padding()
        }.padding([.top],40)
        
        
    }
    
    private func savePet(){
        
        self.pet.name = self.name
        self.pet.birthday = self.birthday
        self.tag = 1
    }
    
    
}

struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        
            SetupNameView().environmentObject(PetModel()).navigationBarBackButtonHidden(true).navigationBarTitle("Setup").navigationViewStyle(StackNavigationViewStyle())
        
    }
}

