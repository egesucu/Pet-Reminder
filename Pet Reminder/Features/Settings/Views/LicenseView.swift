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
import MarkdownUI

struct LicenseView: View {
    @State private var content = ""
    
    var body: some View {
        ScrollView {
            Markdown(content)
                .padding(.all)
        }
        .task(readFile)
        .navigationTitle(Text("license_title"))
    }
    
    @MainActor
    func readFile() async {
        if let fileURL = SharedResources.bundle.url(forResource: "LICENSE", withExtension: "md") {
            do {
                let string = try String(contentsOf: fileURL, encoding: .utf8)
                content = string
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
