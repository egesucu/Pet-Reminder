//
//  ViewExtensions.swift
//  Shared
//
//  Created by Sucu, Ege on 09.05.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI

public extension View {
    func onChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        onChange(of: value, initial: initial) {
            Task { @MainActor in
                await action()
            }
        }
    }

    func onChange<V: Equatable>(
        of value: V,
        initial: Bool = false,
        action: @escaping @MainActor @Sendable (_ oldValue: V, _ newValue: V) async -> Void
    ) -> some View {
        onChange(of: value, initial: initial) { oldValue, newValue in
            Task { @MainActor in
                await action(oldValue, newValue)
            }
        }
    }
}
