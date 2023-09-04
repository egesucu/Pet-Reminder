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
            await requestProducts()
        }
    }

    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)

            var newConsumables: [Product] = []

            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newConsumables.append(product)
                default:
                    print("Unknown product")
                }
            }

            consumables = sortByPrice(newConsumables)
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}
