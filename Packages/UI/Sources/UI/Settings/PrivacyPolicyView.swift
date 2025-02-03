//
//  PrivacyPolicyView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

public struct PrivacyPolicyView: View {
    public var body: some View {
        ScrollView {
            VStack {
                Text("privacy_policy_content", bundle: .module)
                    .padding(.all)
            }
        }
        .navigationTitle(Text("privacy_policy_title", bundle: .module))

    }
}

#Preview {
    PrivacyPolicyView()
}
