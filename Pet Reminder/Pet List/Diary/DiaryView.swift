//
//  DiaryView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 18.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct DiaryView: View {
    
    @State private var diaryViewModel: DiaryViewModel
    
    init(diaryViewModel: DiaryViewModel) {
        self.diaryViewModel = diaryViewModel
    }
    
    var body: some View {
        ForEach(diaryViewModel.diaries) { diary in
            petDiaryView(diary: diary)
        }
    }
    
    func petDiaryView(diary: Diary) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
            VStack {
                Text(diary.title)
                    .font(.title)
                Text(diary.date.formatted())
                    .font(.headline)
                Text(diary.content)
            }
        }
    }
}

#Preview {
    DiaryView(diaryViewModel: .init(pet: Pet()))
        .modelContainer(PreviewSampleData.container)
}
