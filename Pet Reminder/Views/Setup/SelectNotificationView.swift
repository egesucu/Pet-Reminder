//
//  SelectNotificationView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct SelectNotificationView: View {
    
    
    @State private var selectedIndex : Int?
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @StateObject var petManager : PetManager
    
    var body: some View {
        
        VStack{
            Text("Notification")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            NavigationLink(destination: NotificationView(petManager: petManager).environment(\.managedObjectContext, viewContext)) {
                ZStack(alignment: .center) {
                    Image("morning")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .overlay(Color.black.opacity(0.5))
                        .cornerRadius(30)
                        .shadow(color: Color(UIColor.label).opacity(0.5), radius: 10)
                        .padding()
                    
                    
                    Text("Morning")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }.onTapGesture {
                petManager.type = .morning
            }
            
            NavigationLink(destination: NotificationView(petManager: petManager)) {
                ZStack(alignment: .center) {
                    Image("evening")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .overlay(Color.black.opacity(0.5))
                        .cornerRadius(30)
                        .shadow(color: Color(UIColor.label).opacity(0.5), radius: 10)
                        .padding()
                    Text("Evening")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }
            .onTapGesture {
                petManager.type = .evening
            }
            NavigationLink(destination: NotificationView(petManager: petManager)){
                ZStack(alignment: .center) {
                    Image("both")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .overlay(Color.black.opacity(0.5))
                        .cornerRadius(30)
                        .shadow(color: Color(UIColor.label).opacity(0.5), radius: 10)
                        .padding()
                    Text("Both")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }
            .onTapGesture {
                petManager.type = .both
            }
            
            
            
            .navigationBarTitle("Notification Select", displayMode: .inline)
            
        }.padding()
    }
    
    
    
}

struct SelectNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView{
                SelectNotificationView(petManager: PetManager())
            }
            
            
        }
        
    }
}
