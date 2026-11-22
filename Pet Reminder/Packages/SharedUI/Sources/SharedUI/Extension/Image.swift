//
//  Image+Extensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 12.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Shared
import SwiftUI

public extension ImageResource {
    static func generateDefaultData(kind: Kind) -> Self {
        switch kind {
        case .cat:
                .defaultCat
        case .dog:
                .defaultDog
        case .fish:
                .defaultFish
        case .bird:
                .defaultBird
        case .other:
                .defaultOther
        }
    }
}

public extension ImageResource {
    static var defaultCat: Self { .init(name: "default-cat", bundle: SharedResources.bundle) }
    static var defaultDog: Self { .init(name: "default-dog", bundle: SharedResources.bundle) }
    static var defaultFish: Self { .init(name: "default-fish", bundle: SharedResources.bundle) }
    static var defaultBird: Self { .init(name: "default-bird", bundle: SharedResources.bundle) }
    static var defaultOther: Self { .init(name: "default-other", bundle: SharedResources.bundle) }
}
