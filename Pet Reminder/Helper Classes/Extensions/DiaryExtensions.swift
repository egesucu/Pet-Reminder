//
//  DiaryExtensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 18.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import LoremSwiftum

extension Diary {

  var previews: [Diary] {
    var diaries: [Diary] = []

    for _ in 0..<5 {
      let diaryItem = Diary(
        date: .randomDate(),
        title: Lorem.title,
        content: Lorem.sentences(20))
      diaries.append(diaryItem)
    }

    return diaries
  }
}
