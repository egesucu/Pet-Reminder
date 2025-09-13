//
//  ESEventDetailView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 3.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import EventKitUI

struct ESEventDetailView: UIViewControllerRepresentable {

    typealias UIViewControllerType = EKEventViewController

    var event: EKEvent

    func makeUIViewController(context: Context) -> EKEventViewController {
        let view = EKEventViewController()
        view.event = event
        view.allowsEditing = true
        view.allowsCalendarPreview = true
        view.delegate = context.coordinator
        return view
    }

    func updateUIViewController(_ uiViewController: EKEventViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, EKEventViewDelegate {

        var parent: ESEventDetailView

        init(_ parent: ESEventDetailView) {
            self.parent = parent
        }

        func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
            Task {
                controller.dismiss(animated: true, completion: nil)
            }
        }

    }

}
