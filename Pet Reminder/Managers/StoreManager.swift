//
//  StoreManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import Observation
import OSLog
import StoreKit

@Observable
class StoreManager {

  // MARK: Lifecycle

  init() {
    Task {
      await requestProducts()
    }
  }

  // MARK: Internal

  var consumables: [Product] = []

  @ObservationIgnored let productIDs = [Strings.donateTeaID, Strings.donateFoodID]

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

  func sortByPrice(_ products: [Product]) -> [Product] {
    products.sorted(by: { $0.price < $1.price })
  }
}
