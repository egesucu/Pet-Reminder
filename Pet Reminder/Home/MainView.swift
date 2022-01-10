//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name , ascending: true)])
    var pets : FetchedResults<Pet>
    @StateObject var storeManager : StoreManager
    @State private var petSaved = false
    @State private var loading = true
    
    let feedChecker = DailyFeedChecker.shared
    
    var body: some View{
        ZStack(alignment: .center){
            if petSaved || UserDefaults.standard.bool(forKey: "petSaved"){
                HomeManagerView(storeManager: storeManager)
            } else {
                HelloView()
                if loading {
                    ProgressView(LocalizedStringKey("Loading"))
                        .frame(width: 100, height: 100, alignment: .center)
                }
            }
            
        }
        .onAppear(perform: {
            resetFeedTimes()
        })
        .onChange(of: pets.count) { newValue in
            if newValue > 0{
                petSaved = true
                UserDefaults.standard.set(true, forKey: "petSaved")
            } else {
                UserDefaults.standard.set(false, forKey: "petSaved")
                petSaved = false
            }
            loading = false
        }
    }
  
    func resetFeedTimes(){
        if pets.count > 0{
            feedChecker.resetLogic(pets: pets, context: context)
        }
    }
}

