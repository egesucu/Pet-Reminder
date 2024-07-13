//
//  PetCell.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

struct PetCell: View {

    var pet: Pet

    public var body: some View {
        HStack {
            ESImageView(data: pet.image)
                .padding(.trailing, 10)
                .frame(width: 150, height: 150)
            VStack {
                Text(pet.name)
                    .foregroundStyle(ESColor.label)
                    .font(.title)
                    .minimumScaleFactor(0.2)
                    .lineLimit(3)
                if let feeds = pet.feeds {
                    if feeds.count > 0,
                       let lastFeed = feeds.last {
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
}

#Preview {
    NavigationStack {
        PetCell(pet: .preview)
            .modelContainer(PreviewSampleData.container)
    }
}
