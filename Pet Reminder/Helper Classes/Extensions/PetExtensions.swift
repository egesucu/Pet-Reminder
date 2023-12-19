//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import UIKit

extension Pet {
  var selection: FeedTimeSelection {
    get {
      FeedTimeSelection(rawValue: choice) ?? .both
    }
    set {
      choice = newValue.rawValue
    }
  }

  var feedsArray: [Feed] {
    let feeds = feeds ?? []
    return feeds.sorted { first, second in
      first.wrappedFeedDate < second.wrappedFeedDate
    }
  }

  var vaccinesArray: [Vaccine] {
    let vaccines = vaccines ?? []
    return vaccines.sorted { first, second in
      first.date < second.date
    }
  }

  var preview: Pet {
    let firstPet = previews.first ?? .init()
    return firstPet
  }

  var previews: [Pet] {
    var pets: [Pet] = []
    for petName in Strings.demoPets {
      let pet = Pet(
        birthday: .randomDate(),
        name: petName,
        choice: [0,1,2].randomElement() ?? 0,
        createdAt: .randomDate(),
        eveningFed: false,
        eveningTime: nil,
        image: UIImage(resource: .defaultAnimal).jpegData(compressionQuality: 0.8),
        morningFed: false,
        morningTime: nil)
      pet.feeds = Feed().previews
      pet.vaccines = Vaccine().previews
      pet.diaries = Diary().previews
      pets.append(pet)
    }
    return pets
  }

  func removeDiary(diary: Diary) {
    diaries?.removeAll { $0.date == diary.date }
  }
}
