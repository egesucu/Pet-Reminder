//
//  SettingsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    @StateObject var storeManager : StoreManager
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("App Settings")) {
                    NavigationLink("Pets", destination: PetListView().environment(\.managedObjectContext, viewContext))
                }
                Section {
                    NavigationLink("Donate") {
                        DonateView(storeManager: storeManager)
                    }
                } header: {
                    Text("Buy a 🫖")
                }


            }
            
            .navigationTitle(Text("Settings"))
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(storeManager: StoreManager())
    }
}


struct DonateView: View {
    
    @StateObject var storeManager : StoreManager
    
    var body: some View{
        VStack{
            Text("Donate Us")
                .font(.largeTitle)
                .padding()
            Text("This app began as a free app and still is a free app. This app was create from an indie developer as a hobby project and through the years, it has become the app that has more than tousands of users. We're so grateful to have you as users.")
                .padding()
            Text("Note that this is completely a volunteer donation. Feel free to do or just read those sentences.")
                .padding()
            ForEach(storeManager.products, id: \.productIdentifier){ product in
                
                if storeManager.userDidPurchase(product) {
                    Text("You already donated us before, thank you for the donation!")
                        .foregroundColor(.green)
                } else {
                    HStack {
                        Button {
                            storeManager.purchaseProduct(product)
                        } label: {
                            Text("\(product.localizedPrice)")
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(product.localizedTitle)
                            Text(product.localizedDescription)
                        }
                    }.padding()
                }
            }

        }.onAppear {
            if storeManager.userCanPurchase{
                storeManager.getProducts()
            }
        }
    }
    
    
}
