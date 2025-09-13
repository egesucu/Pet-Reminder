//
//  LicenseView.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 17.05.2025.
//  Copyright © 2025 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import OSLog

struct LicenseView: View {
    @State private var context: AttributedString = .init()

    var body: some View {
        ScrollView {
            VStack {
                Text(context).padding(.all)
            }
        }
        .task(readFile)
        .navigationTitle(Text(.licenseTitle))
    }

    func readFile() async {
        if let fileURL = SharedResources.bundle.url(forResource: "LICENSE", withExtension: "md") {
            do {
                let data = try AttributedString.convertMarkdown(url: fileURL)
                context = data
            } catch {
                Logger().error("Could not read the License file: \(error)")
            }
        } else {
            Logger().error("LICENSE.md file not found in \(SharedResources.bundle)")
        }
    }
}

#Preview {
    NavigationStack {
        LicenseView()
    }
}
