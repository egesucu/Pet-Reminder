//
//  PetCell.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import SwiftUI

struct PetCell: View {
    @ObservedObject var pet: Pet
    var body: some View{
        HStack{
            ESImageView(data: pet.image)
                .padding([.top,.trailing,.bottom],10)
                .frame(maxWidth: 150, maxHeight: 150)
            Text(pet.name ?? "Viski")
                .foregroundColor(Color(uiColor: .label))
                .font(.title)
                .minimumScaleFactor(0.5)
                .padding()
        }
    }
}

struct PetCell_Previews: PreviewProvider {
    static var previews: some View {
        let pet = Pet(context: PersistenceController.preview.container.viewContext)
        pet.name = "Viski"
        return PetCell(pet: pet)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
