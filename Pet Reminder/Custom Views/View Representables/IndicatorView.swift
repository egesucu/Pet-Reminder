//
//  IndicatorView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct IndicatorView: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<IndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<IndicatorView>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
