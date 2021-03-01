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
    @Environment(\.presentationMode)
    private var presentationMode
    
    
    @State private var name = ""
    @State private var birthday = Date()
    @State private var showingAlert = false
    @State var selection: Int? = nil
    
    @Binding var comingFromMain : Bool
    
    @StateObject var demoPet = DemoPet()
    
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
                NavigationLink(destination: SetupPhotoView(demoPet: demoPet).environment(\.managedObjectContext, viewContext), tag: 1, selection : $selection) {
                    Button(action: {
                           saveName(name: name)
                    }, label: {
                        Text("Next")
                    })
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
            .navigationBarItems(leading: self.comingFromMain ? AnyView(cancelButton) : AnyView(EmptyView()))
            
        }
        
    }
    
    var cancelButton : some View {
        Button(action : { self.presentationMode.wrappedValue.dismiss()},label : {
            Text("Cancel")
        })
    }
    
    func saveName(name: String){
        if name.isEmpty{
            self.selection = 0
            self.showingAlert = true
        } else {
            demoPet.name = name
            demoPet.birthday = birthday
            self.showingAlert = false
            self.selection = 1
        }
    }
}


struct SetupNameView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            SetupNameView(comingFromMain: .constant(false), demoPet: DemoPet())
        }
        
        
    }
}

enum NotificationType{
    case morning, evening, both
}


class DemoPet : ObservableObject {
    
    var name: String
    var birthday : Date
    var petImage : UIImage
    var type : NotificationType
    
    init(){
        name = ""
        birthday = Date()
        petImage = UIImage()
        type = .morning
    }
    
    static let demoPet = DemoPet()
    
    
    
    func emptyName(name: String)->Bool{
        return name.isEmpty
    }
    
}

