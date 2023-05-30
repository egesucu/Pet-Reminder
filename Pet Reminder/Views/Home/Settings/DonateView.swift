//
//  DonateView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.12.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct DonateView: View {
    
    @StateObject var storeManager : StoreManager
    @State private var showAlert = false
    @State private var alertText = ""
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View{
        ScrollView{
            Assets.defaultAnimal.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding([.top,.bottom],10)
            Text(Strings.donateUsContext)
                .padding()
            Text(Strings.donateUsComment)
                .padding()
            ForEach(storeManager.products, id: \.localizedPrice){ product in
                
                if storeManager.userDidPurchase(product) {
                    Text(Strings.donateUsDonated)
                        .foregroundColor(tintColor)
                        .padding()
                }
                HStack{
                    Button {
                        self.generateHaptic()
                        storeManager.purchaseProduct(product)
                    } label: {
                        Text(product.localizedPrice).foregroundColor(Color(uiColor: .systemBackground))
                    }
                    .buttonStyle(.borderedProminent)
                    .padding([.trailing,.leading],5)
                    Text(product.localizedTitle)
                    Spacer()
                }.padding()
            }.onAppear{
                storeManager.products.sort(by: { $0.price.doubleValue < $1.price.doubleValue })
            }

            Button {
                self.storeManager.clearPreviousPurchases()
                
                self.generateHaptic()
                
                self.alertText = Strings.donateUsClearedSuccessfull
                self.showAlert = true
                
            } label: {
                Text(Strings.donateUsClear)
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
        .navigationTitle(Text(Strings.donateUsTitle))
    }
    
    func generateHaptic(){
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
    }
    
    
}
