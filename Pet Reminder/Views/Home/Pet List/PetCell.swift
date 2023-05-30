//
//  PetCell.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetCell: View {
    @ObservedObject var pet: Pet
    var body: some View{
        HStack{
            ESImageView(data: pet.image)
                .padding([.top,.trailing,.bottom],10)
                .frame(maxWidth: 150, maxHeight: 150)
            VStack {
                Text(pet.name ?? "Viski")
                    .foregroundColor(Color(uiColor: .label))
                    .font(.title)
                    .minimumScaleFactor(0.5)
                    .padding()
                if let feedSet = pet.feeds,
                   let feeds = feedSet.allObjects as? [Feed],
                   feeds.count > 0,
                   let lastFeed = feeds.last{
                    if lastFeed.eveningFed,
                       let eveningTime = lastFeed.eveningFedStamp{
                        VStack(alignment: .leading){
                            Text(Strings.lastFeedTitle)
                                .bold()
                            Text("\(eveningTime.formatted())")
                        }
                    } else if lastFeed.morningFed,
                              let morningTime = lastFeed.morningFedStamp{
                        VStack(alignment: .leading){
                            Text(Strings.lastFeedTitle)
                                .bold()
                            Text(morningTime.formatted())
                        }
                    }
                }
            }
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
