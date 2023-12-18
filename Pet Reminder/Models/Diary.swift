//
//  Diary.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 18.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

@Model public class Diary {
    let date: Date
    let title: String
    let content: String
    var pet: Pet?
    
    public init(
        date: Date = .now,
        title: String = "",
        content: String = ""
    ) {
        self.date = date
        self.title = title
        self.content = content
    }
}
