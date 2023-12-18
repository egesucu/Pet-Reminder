//
//  DiaryViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 18.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Observation

protocol ESViewModel {
    associatedtype ViewAction
    
    func evaluateAction(action: ViewAction) async
}


@Observable
class DiaryViewModel: ESViewModel {
    
    var pet: Pet
    
    var diaries: [Diary] {
        pet.diaries ?? []
    }
    
    init(pet: Pet) {
        self.pet = pet
    }
    
    enum ViewAction {
        case viewAppeared
        case removeDiary(Diary)
        case addDiary
    }

    func evaluateAction(action: ViewAction) async {
        switch action {
            case .viewAppeared:
                break
            case let .removeDiary(diary):
                pet.removeDiary(diary: diary)
            case .addDiary:
                addDiary()
        }
    }
    
    private func addDiary() {
        
    }
    
}
