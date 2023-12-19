//
//  Diary.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 18.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftData
import SwiftUI

@Model
public class Diary {

  // MARK: Lifecycle

  public init(
    date: Date = .now,
    title: String = "",
    content: String = "")
  {
    self.date = date
    self.title = title
    self.content = content
  }

  // MARK: Internal

  let date: Date
  let title: String
  let content: String
  var pet: Pet?
}
