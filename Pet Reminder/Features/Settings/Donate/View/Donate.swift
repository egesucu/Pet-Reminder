//
//  Donate.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import StoreKit
import OSLog
import Shared

struct Donate: View {
    @State private var consumables: [Product] = []
    let productIDs = [Strings.donateTeaID, Strings.donateFoodID]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing16) {
                
                animalImage
                
                Text(.donateUsContext)
                
                Text(.donateUsComment)

                products
            }
            .padding(.horizontal, .spacing8)
            .task(requestProducts)
        }
        .navigationTitle(Text(.donateUsTitle))
    }
}

// MARK: - Helper UI
private extension Donate {
    
    var animalImage: some View {
        HStack(spacing: .zero) {
            Spacer()
            Image(.defaultOther)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
                .clipShape(.circle)
            Spacer()
        }
    }
    
    var products: some View {
        LazyVStack(spacing: .spacing8) {
            ForEach(consumables) { product in
                ProductView(product, prefersPromotionalIcon: true)
                    .onInAppPurchaseCompletion { product, result in
                        Task {
                            await purcahaseCompleted(product: product, result: result)
                        }
                    }
                    .onInAppPurchaseStart { product in
                        Logger
                            .settings
                            .info("Purchasing the product: \(product.displayName)")
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}

// MARK: - Helper Functions
private extension Donate {
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            var newConsumables: [Product] = []

            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newConsumables.append(product)
                default:
                    Logger
                        .settings
                        .error("We don't support other iAP product types.")
                }
            }

            withAnimation {
                consumables = newConsumables.sorted { return $0.price < $1.price }
            }
        } catch {
            Logger
                .settings
                .error("Failed product request from the App Store server: \(error.localizedDescription)")
        }
    }
}

// MARK: - After Purchase Actions
private extension Donate {
    /// Checks the result of the purchase
    func purcahaseCompleted(
        product: Product,
        result: Result<Product.PurchaseResult, any Error>
    ) async {
        switch result {
        case .success(let result):
            switch result {
            case .success(let output):
                switch output {
                case .verified(let transaction):
                    Logger
                        .settings
                        .info("Verified Transaction: \(transaction.debugDescription)")
                    await transaction.finish()
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

#if DEBUG
#Preview {
    NavigationStack {
        Donate()
    }
}
#endif
