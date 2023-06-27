//
//  PetCell.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetCell: View {

    var pet: Pet

    var body: some View {
        HStack {
            ESImageView(data: pet.image)
                .padding([.top, .trailing, .bottom], 10)
                .frame(maxWidth: 150, maxHeight: 150)
            VStack {
                Text(pet.name ?? "")
                    .foregroundColor(Color(uiColor: .label))
                    .font(.title)
                    .minimumScaleFactor(0.5)
                    .padding()
                if let feeds = pet.feeds,
                   feeds.count > 0,
                   let lastFeed = feeds.last {
                    if lastFeed.eveningFed ?? false,
                       let eveningTime = lastFeed.eveningFedStamp {
                        VStack(alignment: .leading) {
                            Text("last_feed_title")
                                .bold()
                            Text("\(eveningTime.formatted())")
                        }
                    } else if lastFeed.morningFed ?? false,
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

// #Preview {
//    MainActor.assumeIsolated {
//        PetCell(pet: PreviewSampleData.previewPet)
//            .modelContainer(PreviewSampleData.container)
//    }
//    
// }

struct PetCellDemo: PreviewProvider {
    static var previews: some View {

        return NavigationView {
            PetCell(pet: .demo)
                .modelContainer(for: Pet.self)
        }
    }
}
