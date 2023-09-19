//
//  DonateView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import StoreKit
import OSLog

struct DonateView: View {

    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    @State private var viewModel = StoreManager()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image(.defaultAnimal)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .padding(.vertical, 10)
                    Spacer()
                }
                Text("donate_us_context")
                    .padding()
                Text("donate_us_comment")
                    .padding()
                ForEach(viewModel.consumables, id: \.self) { product in
                    ProductView(product, prefersPromotionalIcon: false)
                        .onInAppPurchaseCompletion { product, result in
                            purcahaseCompleted(product: product, result: result)
                        }
                        .onInAppPurchaseStart { product in
                            Logger
                                .viewCycle
                                .info("Purchasing the product: \(product.displayName)")
                        }
                }
            }.padding(.horizontal)
        }.navigationTitle(Text("donate_us_title"))
    }

    func purcahaseCompleted(product: Product, result: Result<Product.PurchaseResult, Error>) {
        switch result {
        case .success(let result):
            switch result {
            case .success(let res):
                switch res {
                case .verified(let transaction):
                    Logger
                        .viewCycle
                        .info("Verified Transaction: \(transaction.debugDescription)")
                    Task {
                        await transaction.finish()
                    }
                case .unverified(let transaction, let error):
                    Logger
                        .viewCycle
                        .info("Unverified Transaction: \(transaction.debugDescription)")
                    Logger
                        .viewCycle
                        .error("Unverified Transaction Error: \(error.localizedDescription)")
                }
            case .pending:
                Logger
                    .viewCycle
                    .info("Pending transaction")
            case .userCancelled:
                Logger
                    .viewCycle
                    .info("User cancelled the pop-up")
            @unknown default:
                Logger
                    .viewCycle
                    .info("Unknown Case occured")
            }
        case .failure(let failure):
            Logger
                .viewCycle
                .error("Purchase failed: \(failure.localizedDescription)")
        }
    }
}

#Preview {
    DonateView()
}
