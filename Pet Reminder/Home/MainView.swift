//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CloudKit

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var pets : FetchedResults<Pet>
    
    let feedChecker = DailyFeedChecker.shared
    
    var body: some View{
        VStack{
            if pets.count > 0 {
                HomeManagerView().environment(\.managedObjectContext, context)
            } else {
                HelloView().environment(\.managedObjectContext, context)
            }
        }
        .onAppear { resetFeedTimes() }
    }
    
    func resetFeedTimes(){
        if pets.count > 0{
            feedChecker.resetLogic(pets: pets, context: context)
        }
    }
}

