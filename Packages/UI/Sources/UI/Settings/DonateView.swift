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
import SharedModels

public struct DonateView: View {

    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)
    @State private var viewModel = StoreManager()

    public var body: some View {
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
                Text("donate_us_context", bundle: .module)
                    .padding()
                Text("donate_us_comment", bundle: .module)
                    .padding()
                ForEach(viewModel.consumables, id: \.self) { product in
                    ProductView(product, prefersPromotionalIcon: false)
                        .onInAppPurchaseCompletion { product, result in
                            purcahaseCompleted(product: product, result: result)
                        }
                        .onInAppPurchaseStart { product in
                            Logger
                                .settings
                                .info("Purchasing the product: \(product.displayName)")
                        }
                }
            }.padding(.horizontal)
        }.navigationTitle(Text("donate_us_title", bundle: .module))
    }

    func purcahaseCompleted(
        product: Product,
        result: Result<Product.PurchaseResult, any Error>
    ) {
        switch result {
        case .success(let result):
            switch result {
            case .success(let res):
                switch res {
                case .verified(let transaction):
                    Logger
                        .settings
                        .info("Verified Transaction: \(transaction.debugDescription)")
                    Task {
                        await transaction.finish()
                    }
                case .unverified(let transaction, let error):
                    Logger
                        .settings
                        .info("Unverified Transaction: \(transaction.debugDescription)")
                    Logger
                        .settings
                        .error("Unverified Transaction Error: \(error.localizedDescription)")
                }
            case .pending:
                Logger
                    .settings
                    .info("Pending transaction")
            case .userCancelled:
                Logger
                    .settings
                    .info("User cancelled the pop-up")
            @unknown default:
                Logger
                    .settings
                    .info("Unknown Case occured")
            }
        case .failure(let failure):
            Logger
                .settings
                .error("Purchase failed: \(failure.localizedDescription)")
        }
    }
}

#Preview {
    DonateView()
}
