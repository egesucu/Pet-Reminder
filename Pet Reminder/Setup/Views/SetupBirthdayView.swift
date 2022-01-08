//
//  SetupBirthdayView.swift
//  SetupBirthdayView
//
//  Created by egesucu on 30.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct SetupBirthdayView: View {
    
    @State private var birthday = Date()
    var petManager: PetManager
    
    var body: some View {
        VStack{
            DatePicker("select_date", selection: $birthday, displayedComponents: .date)
                .padding([.top,.bottom])
                .multilineTextAlignment(.center)
                .onChange(of: birthday, perform: { date in
                    petManager.birthday = date
                })
                
        }
        .padding()
        .navigationTitle(Text("birthday_title"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: SetupPhotoView(petManager: petManager),
                    label: {
                        Text("continue")
                    })
                .foregroundColor(.green)
                .font(.body.bold())
            }
        }
    }
    
}

struct SetupBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupBirthdayView(petManager: PetManager())
        }
    }
}
