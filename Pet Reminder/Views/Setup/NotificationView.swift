//
//  NotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    
    @StateObject var petManager : PetManager
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var showProgressStatus = false
    @State private var petSaved = false
    @State private var finishProgress = false
    @State private var morningTime = Date()
    @State private var eveningTime = Date()
    
    var body: some View {
        VStack {
            
            switch (petManager.type){
            
            case .morning:
                MorningNotificationView(morningTime: $morningTime)
            case .evening:
                EveningNotificationView(eveningTime: $eveningTime)
            case .both:
                BothNotificationView(morningTime: $morningTime, eveningTime: $eveningTime)
            }
            Button(action: savePet, label: {
                Text("Setup")
            })
            .font(.title)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .fullScreenCover(isPresented: $petSaved, content: {
                HomeManagerView().environment(\.managedObjectContext, viewContext)
                
            })
            
        }.padding()
    }
    
    func savePet(){
        
        petSaved = self.petManager.savePet(context: viewContext, morningTime: morningTime, eveningTime: eveningTime)
            

    }
    

}

struct MultipleNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(petManager: PetManager())
    }
}
