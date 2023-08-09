//
//  PetCell.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetCell: View {

    var pet: Pet

    var body: some View {
        HStack {
            ESImageView(data: pet.image)
                .padding(.vertical, 10)
                .padding(.trailing, 10)
                .frame(maxWidth: 150, maxHeight: 150)
            VStack {
                Text(pet.name ?? "")
                    .foregroundColor(Color(uiColor: .label))
                    .font(.title)
                    .minimumScaleFactor(0.5)
                    .padding()
                if let feeds = pet.feeds,
                   feeds.count > 0,
                   let feedSet = feeds.allObjects as? [Feed],
                   let lastFeed = feedSet.last {
                    if lastFeed.eveningFed,
                       let eveningTime = lastFeed.eveningFedStamp {
                        VStack(alignment: .leading) {
                            Text("last_feed_title")
                                .bold()
                            Text("\(eveningTime.formatted())")
                        }
                    } else if lastFeed.morningFed,
                              let morningTime = lastFeed.morningFedStamp {
                        VStack(alignment: .leading) {
                            Text("last_feed_title")
                                .bold()
                            Text(morningTime.formatted())
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    return NavigationStack {
        PetCell(pet: .init())
    }
}
