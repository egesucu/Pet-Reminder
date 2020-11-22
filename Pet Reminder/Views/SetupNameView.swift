//
//  SetupNameView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SetupNameView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        VStack{
            NameInputView()
            Spacer()
            BirthdayInputView()
            Spacer()
            NextButton()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea(.all, edges: .all))
        .navigationBarTitle("Personal Information")
        
    }
    
    
}

struct NameInputView : View {
    
    @State private var name = ""
    
    var body: some View {
        VStack{
            Text("Name")
                .font(.largeTitle)
                .padding()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            TextField("Text", text: $name).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                .multilineTextAlignment(.center)
            
        }
        
    }
    
}

struct BirthdayInputView : View {
    
    @State private var birthday = Date()
    
    var body: some View {
        VStack{
            Text("Birthday").font(.largeTitle).padding().lineLimit(1).minimumScaleFactor(0.5)
            DatePicker("Please enter a date", selection: $birthday, displayedComponents: .date)
                .labelsHidden()
                .environment(\.locale, Locale.init(identifier: Locale.current.languageCode ?? "tr"))
                .padding()
                .frame(height: 80)
                .clipped()
            
        }
        
    }
    
}

struct NextButton : View {
    
    @State private var showingAlert = false
    
    var body: some View{
        NavigationLink(destination: SetupPhotoView()) {
            Button("Next") {
//        action goes here
            }
            .font(Font.system(size: 35))
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            .background(Color.green)
            .cornerRadius(60)
            .alert(isPresented: $showingAlert) { () -> Alert in
                Alert(title: Text("Name-Message"))
            }
            .padding()
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

