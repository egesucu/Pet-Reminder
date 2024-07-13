//
//  StoreManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import StoreKit
import Observation
import OSLog

@MainActor
@Observable
public class StoreManager {
    public var consumables: [Product] = []

    @ObservationIgnored let productIDs = [Strings.donateTeaID, Strings.donateFoodID]

    public init() {
        Task {
            await requestProducts()
        }
    }

    public func requestProducts() async {
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
                        .error("Unknwon product")
                }
            }

            consumables = sortByPrice(newConsumables)
        } catch {
            Logger
                .settings
                .error("Failed product request from the App Store server: \(error.localizedDescription)")
        }
    }

    public func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}
