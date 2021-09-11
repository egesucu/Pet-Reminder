//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct HelloView: View {
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var pets : FetchedResults<Pet>
    
    let manager = DataManager.shared
    
    @State private var showSetup = false
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var petsAvailable = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image("pet-reminder")
                    .resizable()
                    .scaledToFit()
                    .padding([.top,.bottom])
                Text("Welcome-Slogan")
                    .padding([.top,.bottom])
                    .font(.title)
                Spacer()
                Text("Welcome-Slogan-2")
                    .padding([.top,.bottom])
                    .font(.body)
                Spacer()
                HStack {
                    Button {
                        self.showSetup.toggle()
                    } label: {
                        Text("Add Pet")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(5)
                    .shadow(radius: 3)
                    .sheet(isPresented: $showSetup, content: { SetupNameView()})
                    
                    Spacer()
                    
                    Button {
                        restoreFromIcloud()
                    } label: {
                        Text("Restore")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.borderless)
                    
                }
                
            }.padding()
            if petsAvailable{
                HomeManagerView().environment(\.managedObjectContext, context)
            }
        }
    }
    
    func restoreFromIcloud(){
        manager.checkIcloudAvailability { result in
            switch result {
            case .success:
                if pets.count > 0{
                    petsAvailable = true
                }
            case .error(let icloudError):
                self.showAlert = true
                self.alertText = icloudError.errorDescription ?? ""
            }
        }
    }
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            HelloView()
        }
        
    }
}

