//
//  PetChangeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct PetChangeView: View {
    
    var pet: Pet
    @State private var nameText = ""
    @State private var petImage : UIImage? = nil
    @State private var birthday = Date()
    @State private var selection : Selection = .both
    
    var body: some View {
        
        VStack {
            Image("default-animal")
                .resizable()
                .frame(width: 200, height: 200, alignment: .center)
            Form{
                TextField("Name", text: $nameText)
                    .onChange(of: nameText, perform: { value in
                        self.changeName(with: value)
                    })
                DatePicker("Date", selection: $birthday, displayedComponents: .date)
                Picker("Notification Settings", selection: $selection) {
                    Text("Morning").tag(selection)
                    Text("Evening").tag(selection)
                    Text("Both").tag(selection)
                }.pickerStyle(SegmentedPickerStyle())
                
            }
            .navigationTitle(pet.name ?? "Pet")
        }
        .onAppear{
            self.birthday = pet.birthday ?? Date()
            self.nameText = pet.name ?? ""
            self.petImage = UIImage(data: pet.image ?? Data()) ?? nil
            self.selection = pet.selection
        }
        
    }
    
    func changeName(with value: String){
        
    }
    
    func changeBirthday(){
        
    }
    
    func changeNotification(with date: Date, for type: NotificationType){
        
    }
}

struct PetChangeView_Previews: PreviewProvider {
    static var previews: some View {
        let pet = Pet(context: PersistenceController.preview.container.viewContext)
        NavigationView {
            PetChangeView(pet: pet)
        }
    }
}
