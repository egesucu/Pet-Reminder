//
//  DonateView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.12.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct DonateView: View {
    
    @StateObject var storeManager : StoreManager
    @State private var showAlert = false
    @State private var alertText = ""
    
    var body: some View{
        ScrollView{
            Image("default-animal")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding([.top,.bottom],10)
            Text("This app began as a free app and still is a free app. This app was create from an indie developer as a hobby project and through the years, it has become the app that has more than tousands of users. We're so grateful to have you as users.")
                .padding()
            Text("Note that this is completely a volunteer donation. Feel free to do.")
                .padding()
            ForEach(storeManager.products, id: \.productIdentifier){ product in
                
                if storeManager.userDidPurchase(product) {
                    Text("You already donated this before, you can do it again if you wish.")
                        .foregroundColor(.green)
                        .padding()
                }
                HStack {
                    Button {
                        self.generateHaptic()
                        storeManager.purchaseProduct(product)
                    } label: {
                        Text(product.localizedPrice)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(product.localizedTitle)
                        Text(product.localizedDescription)
                    }
                }.padding()
            }
            Button {
                self.storeManager.clearPreviousPurchases()
                
                self.generateHaptic()
                
                self.alertText = "Previous Purchase history cleaned successfully."
                self.showAlert = true
                
            } label: {
                Text("Clear Previous Purchase History")
            }
            .buttonStyle(.borderedProminent)
            .alert(alertText, isPresented: $showAlert) {
                
            }

        }.onAppear {
            if storeManager.userCanPurchase{
                storeManager.getProducts()
            }
        }
        .navigationTitle(Text("Donate Us"))
    }
    
    func generateHaptic(){
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
    }
    
    
}
