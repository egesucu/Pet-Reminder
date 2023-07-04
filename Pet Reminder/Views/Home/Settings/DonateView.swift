//
//  DonateView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.12.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct DonateView: View {

    var storeManager: StoreManager
    @State private var showAlert = false
    @State private var alertText = ""
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        ScrollView {
            Image(.defaultAnimal)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding(.vertical, 10)
            Text("donate_us_context")
                .padding()
            Text("donate_us_comment")
                .padding()
            ForEach(storeManager.products, id: \.localizedPrice) { product in

                if storeManager.userDidPurchase(product) {
                    Text("donate_us_donated")
                        .foregroundColor(.accentColor)
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
                    .padding(.horizontal, 5)
                    Text(product.localizedTitle)
                    Spacer()
                }.padding()
            }.onAppear {
                storeManager.products.sort(by: { $0.price.doubleValue < $1.price.doubleValue })
            }

            Button {
                self.storeManager.clearPreviousPurchases()

                self.generateHaptic()

                self.alertText = String(localized: "donate_us_cleared_successfull")
                self.showAlert = true

            } label: {
                Text("donate_us_clear")
                    .foregroundColor(Color(uiColor: .systemBackground))
            }
            .buttonStyle(.borderedProminent)
            .alert(alertText, isPresented: $showAlert) {

            }

        }.onAppear {
            if storeManager.userCanPurchase {
                storeManager.getProducts()
            }
        }
        .navigationTitle(Text("donate_us_title"))
    }

    func generateHaptic() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
    }

}
