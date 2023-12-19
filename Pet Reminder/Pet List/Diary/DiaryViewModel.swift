//
//  DiaryViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 18.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Observation
import SwiftUI

// MARK: - ESViewModel

protocol ESViewModel {
  associatedtype ViewAction

  func evaluateAction(action: ViewAction) async
}

// MARK: - DiaryViewModel

@Observable
class DiaryViewModel: ESViewModel {

  // MARK: Lifecycle

  init(pet: Pet) {
    self.pet = pet
  }

  // MARK: Internal

  enum ViewAction {
    case viewAppeared
    case removeDiary(Diary)
    case addDiary
  }

  var pet: Pet

  var diaries: [Diary] {
    pet.diaries ?? []
  }

  func evaluateAction(action: ViewAction) async {
    switch action {
    case .viewAppeared:
      break
    case .removeDiary(let diary):
      pet.removeDiary(diary: diary)
    case .addDiary:
      addDiary()
    }
  }

  // MARK: Private

  private func addDiary() { }

}
