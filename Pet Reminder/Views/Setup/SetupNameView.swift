//
//  SetupNameView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupNameView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var name = ""
    @State private var birthday = Date()
    @State private var showingAlert = false
    @State var selection: Int? = nil
    
    @StateObject var petManager = PetManager()
    
    var body: some View {
        
        NavigationView {
            VStack{
                Text("Name")
                    .font(.title)
                    .padding()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                TextField("Text", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
                Text("Birthday").font(.title).padding().lineLimit(1).minimumScaleFactor(0.5)
                DatePicker("Please enter a date", selection: $birthday, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                    .padding()
                    .labelsHidden()
                Spacer()
                NavigationLink(destination: SetupPhotoView(petManager: petManager).environment(\.managedObjectContext, viewContext), tag: 1, selection : $selection) { EmptyView()}
                
                Button(action: {
                    petManager.saveNameAndBirthday(name: name, birthday: birthday)
                        self.selection = 1
                    
                }, label: {
                    Text("Next")
                    
                })
                    .buttonStyle(NextButton(conditionMet: name.isEmpty))
                
            }
            .navigationBarTitle("Personal Information")
        }
    }
    
}

struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNameView(petManager: PetManager())
    }
}
