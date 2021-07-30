//
//  SetupNotificationView.swift
//  SetupNotificationView
//
//  Created by egesucu on 30.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct SetupNotificationView: View {
    
    @State private var feedType = 0
    @State private var morningFeed = Date()
    @State private var eveningFeed = Date()
    @State private var showHomeSheet = false
    
    var petManager : PetManager
    
    var body: some View {
        
        VStack{
            
            Text("Choose a Feed Time")
                .font(.title).bold()
            .padding([.top,.bottom])
            
            Picker(selection: $feedType, label: Text("Choose a type")) {
                Text("Both").tag(0)
                Text("Morning").tag(1)
                Text("Evening").tag(2)
            }.pickerStyle(.segmented)
                .padding([.top,.bottom])
            
            withAnimation {
                FeedView()
                    .padding([.top,.bottom])
            }
            
            Button {
                self.showHomeSheet.toggle()
            } label: {
                Text("Add Animal")
            }

        }
    }

    @ViewBuilder
    func FeedView() -> some View{
        
        if feedType == 0{
            HStack {
                DatePicker("Morning", selection: $morningFeed, displayedComponents: .hourAndMinute)
                Spacer()
                DatePicker("Evening", selection: $eveningFeed, displayedComponents: .hourAndMinute)
            }
                
            
                
        } else if feedType == 1 {
            DatePicker("Morning", selection: $morningFeed, displayedComponents: .hourAndMinute)
                
        } else {
            DatePicker("Evening", selection: $eveningFeed, displayedComponents: .hourAndMinute)
                
        }
    }
}

struct SetupNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        SetupNotificationView(petManager: PetManager())
    }
}
