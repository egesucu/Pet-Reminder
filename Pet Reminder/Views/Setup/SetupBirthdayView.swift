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
            Text("Birthday")
                .font(.title).bold()
            .padding([.top,.bottom])
            DatePicker("Select the Date", selection: $birthday, displayedComponents: .date)
                .padding([.top,.bottom])
                .multilineTextAlignment(.center)
                .onAppear(){
                    petManager.getBirthday(date: Date())
                }
                .onChange(of: birthday, perform: { value in
                    petManager.getBirthday(date: value)
                })
                
        }
        .padding()
//        TODO: Fix the Localization nonsense here.
        .navigationTitle("Birthday ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: SetupPhotoView(petManager: petManager),
                    label: {
                        Text("Continue")
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
