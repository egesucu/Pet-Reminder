//
//  PetCell.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SwiftData

struct PetCell: View {

    var pet: Pet

    var body: some View {
        HStack {
            if let imageData = pet.image,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .petImageStyle()
                    .padding(.trailing, 10)
                    .frame(width: 150, height: 150)
            } else {
                Image(.generateDefaultData(type: pet.type))
                    .petImageStyle()
                    .padding(.trailing, 10)
                    .frame(width: 150, height: 150)
            }

            VStack {
                Text(pet.name)
                    .foregroundStyle(Color.label)
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
            .modelContainer(DataController.previewContainer)
    }
}
