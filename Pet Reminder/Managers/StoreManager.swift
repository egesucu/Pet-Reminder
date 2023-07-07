//
//  StoreManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import StoreKit
import Observation

@Observable
class StoreManager {
    var consumables: [Product] = []

    @ObservationIgnored let productIDs = [Strings.donateTeaID, Strings.donateFoodID]

    init() {
        Task {
            // During store initialization, request products from the App Store.
            await requestProducts()
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            // Request products from the App Store using the identifiers
            let storeProducts = try await Product.products(for: productIDs)

            var newConsumables: [Product] = []

            // Filter the products into categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newConsumables.append(product)
                default:
                    // Ignore this product.
                    print("Unknown product")
                }
            }

            // Sort each product category by price, lowest to highest, to update the store.
            consumables = sortByPrice(newConsumables)
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}
