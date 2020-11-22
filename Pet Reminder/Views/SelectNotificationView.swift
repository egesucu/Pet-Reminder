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
    
    
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .center,spacing: 5){
                
                Group {
                    Spacer()
                    Text("Notification").font(.largeTitle).multilineTextAlignment(.center).lineLimit(1).minimumScaleFactor(0.6)
                }
                
                Group {
                    Spacer()
                    ZStack(alignment: .center) {
                        Image("morning").onTapGesture {
                            self.selectedIndex = 0
                        }
                        Text("Morning").foregroundColor(Color(.systemBackground)).font(.largeTitle)
                    }
                    
                }
                
                Group {
                    Spacer()
                    ZStack(alignment: .center) {
                        Image("evening").onTapGesture {
                            self.selectedIndex = 1
                        }
                        Text("Evening").foregroundColor(Color(.systemBackground)).font(.largeTitle)
                    }
                    
                }
                
                Group{
                    Spacer()
                    ZStack(alignment: .center) {
                        Image("both").onTapGesture {
                            self.selectedIndex = 2
                        }
                        Text("Both").foregroundColor(Color(.systemBackground)).font(.largeTitle)
                    }
                    
                    Spacer()
                }
                
                NavigationLink(destination: SingleNotificationView(selectedTime: "Morning-Time"), tag: 0, selection: $selectedIndex) {
                    EmptyView()
                }
                
                NavigationLink(destination: SingleNotificationView(selectedTime: "Evening-Time"), tag: 1, selection: $selectedIndex) {
                    EmptyView()
                }
                
                NavigationLink(destination: MultipleNotificationView(), tag: 2, selection: $selectedIndex) {
                    EmptyView()
                }.navigationBarTitle("Notification Select", displayMode: .inline)
                
            }.padding()
        }
    }
    
    
}

struct SelectNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            SelectNotificationView()
        }.navigationBarBackButtonHidden(false)
       
    }
}
