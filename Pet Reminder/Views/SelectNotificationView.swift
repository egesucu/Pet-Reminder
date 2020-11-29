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
    
    var name : String
    var birthday : Date
    var petImage : Image
    
    
    var body: some View {
        
        VStack{
            Text("Notification")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            NavigationLink(destination: SingleNotificationView(selectedTime: "Morning-Time")) {
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
            }
            
            NavigationLink(destination: SingleNotificationView(selectedTime: "Evening-Time")) {
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
            
            NavigationLink(destination: MultipleNotificationView()){
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
            
            
            
            .navigationBarTitle("Notification Select", displayMode: .inline)
            
        }.padding()
    }
    
    
    
}

struct SelectNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView{
                SelectNotificationView(name: "", birthday: Date(), petImage: Image("default-animal"))
            }
            
            
        }
        
    }
}
