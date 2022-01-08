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
            Text("donate_us_context")
                .padding()
            Text("donate_us_comment")
                .padding()
            ForEach(storeManager.products, id: \.productIdentifier){ product in
                
                if storeManager.userDidPurchase(product) {
                    Text("donate_us_donated")
                        .foregroundColor(.green)
                        .padding()
                }
                HStack {
                    Button {
                        self.generateHaptic()
                        storeManager.purchaseProduct(product)
                    } label: {
                        Text(product.localizedPrice).foregroundColor(Color(uiColor: .systemBackground))
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
                
                self.alertText = "donate_us_cleared_successfull"
                self.showAlert = true
                
            } label: {
                Text("donate_us_clear")
                    .foregroundColor(Color(uiColor: .systemBackground))
            }
            .buttonStyle(.borderedProminent)
            .alert(alertText, isPresented: $showAlert) {
                
            }

        }.onAppear {
            if storeManager.userCanPurchase{
                storeManager.getProducts()
            }
        }
        .navigationTitle(Text("donate_us_title"))
    }
    
    func generateHaptic(){
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
    }
    
    
}
