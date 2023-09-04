//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct FeedHistory: View {

    var feeds: [Feed]

    @Environment(\.dismiss) var dismiss

    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    var body: some View {

        NavigationStack {
            List {
                CurrentFeedSection(feeds: feeds)
                PreviousFeedsSection(feeds: feeds)
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark.circle.fill")
                            .tint(tintColor)
                    }
                }
            }
            .navigationTitle(Text("feed_history_title"))
        }
    }
}

#Preview {
    let preview = PersistenceController.preview.container.viewContext
    return NavigationStack {
        FeedHistory(feeds: [.init(context: preview)])
            .environment(\.managedObjectContext, preview)
    }
}
