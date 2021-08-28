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
    
    var body: some View {
        ScrollView {
            VStack {
                
                if pet.image == nil {
                    Image("default-pet")
                } else {
                    ImagePicker(image: $petImage)
                }
                List{
                    Form(content: {
                        HStack{
                            TextField("Name", text: $nameText)
                                .onChange(of: nameText, perform: { value in
                                    self.changeName(with: value)
                                })
                        }
                    })
                }
            }
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
        PetChangeView(pet: Pet())
    }
}
