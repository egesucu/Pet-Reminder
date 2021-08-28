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
    @State private var alertShown = false
    @State private var alertText = ""
    @State private var showProgress = true
    //let feedChecker = DailyFeedChecker.shared
    
    
    
    var body: some View{
        
        ZStack(alignment: .center){
            
            if showProgress{
                ProgressView("Loading")
                    .offset(x: 0, y: 20)
                    .padding()
                    .background(Color.white)
                    .transition(.opacity)
            } else {
                if pets.underestimatedCount > 0 {
                    HomeManagerView().environment(\.managedObjectContext, context)
                } else {
                    HelloView().environment(\.managedObjectContext, context)
                }
            }
            
        }
        .alert(isPresented: $alertShown, content: {
            Alert(title: Text("Error"), message: Text(alertText), dismissButton: .cancel({
                self.alertShown = false
                self.showProgress = false
            }))
        })
        .onAppear {
//            runBackgroundCheck()
//            feedChecker.resetLogic(pets: pets, context: context)
        }
    }
    
//    func runBackgroundCheck(){
//        checkData { result in
//            switch result{
//            case .success(_):
//                self.showProgress = false
//                print("Okey")
//            case .failure(let error):
//                self.alertText = error.localizedDescription
//                self.alertShown = true
//            }
//        }
//    }
    
}

