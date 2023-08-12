//
//  DonateView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import StoreKit

struct DonateView: View {

    @State private var showAlert = false
    @State private var alertText = ""
    @State private var loading = false
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    let store = StoreManager()

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
            ForEach(store.consumables, id: \.self) { product in
                ProductView(product)
                    .onInAppPurchaseCompletion { product, result in
                        purcahaseCompleted(product: product, result: result)
                    }
                    .onInAppPurchaseStart { product in
                        let text = "Purchasing the product: \(product.displayName)"
                        print(text)
                    }
            }
            .navigationTitle(Text("donate_us_title"))
        }
    }
    func generateHaptic() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }

    func purcahaseCompleted(product: Product, result: Result<Product.PurchaseResult, Error>) {
        switch result {
        case .success(let result):
            switch result {
            case .success(let res):
                switch res {
                case .verified(let transaction):
                    print("Verified Transaction: ", transaction)
                    Task {
                        await transaction.finish()
                    }
                case .unverified(let transaction, let error):
                    print("Unverified Transaction: ", transaction)
                    print("Unverified Transaction Error: ", error.localizedDescription)
                }
            case .pending:
                print("Pending transaction")
            case .userCancelled:
                print("User cancelled the pop-up")
            @unknown default:
                print("Unknown Case occured")
            }
            print("Result of the process is: ", result)
        case .failure(let failure):
            print("Purchase failed: ", failure.localizedDescription)
        }
        loading.toggle()
    }
}

#Preview {
    DonateView()
}
