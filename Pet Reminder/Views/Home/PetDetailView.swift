//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by egesucu on 31.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct PetDetailView: View {
    
    var pet : Pet

    var body: some View {
        VStack{
            Image(uiImage: UIImage(data: pet.image ?? Data()) ?? UIImage(named: "default-animal")!)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
            Text(pet.name ?? "Error").font(.title)
        }
        .navigationTitle("Hello \(pet.name ?? "Error")")
    }
}

struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let pet = PersistenceController(inMemory: true).container.viewContext.registeredObjects.first(where: { $0 is Pet}) as! Pet
        
        PetDetailView(pet: pet).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
