//
//  MorningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct MorningCheckboxView: View {

    @Binding var morningOn: Bool

    var body: some View {
        VStack {
            Label {
                Text("feed_selection_morning")
                    .foregroundColor(Color(uiColor: .label))
                    .font(.title2.bold())
            } icon: {
                Image(systemName: morningOn ? SFSymbols.morningToggleSelected : SFSymbols.morningToggle)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.yellow)
                    .font(.largeTitle.bold())
                    .animation(.easeInOut, value: morningOn)
            }.font(.title.bold())
                .padding(.bottom)
            withAnimation {
                Image(systemName: morningOn ? SFSymbols.checked : SFSymbols.notChecked)
                    .font(.system(size: 50))
                    .animation(.easeInOut, value: morningOn)
            }
        }
        .cornerRadius(20)
        .frame(width: 150, height: 150)
    }
}

struct MorningView_Previews: PreviewProvider {
    static var previews: some View {
        MorningCheckboxView(morningOn: .constant(true))
    }
}
