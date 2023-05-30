//
//  PrivacyPolicyView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView{
            VStack{
                Text(Strings.privacyPolicyContent)
                    .padding(.all)
            }
        }.navigationTitle(Text(Strings.privacyPolicyTitle))
        
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
