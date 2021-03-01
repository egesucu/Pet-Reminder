//
//  EventGenerateView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 8.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import EventKitUI

let eventStore = EKEventStore()

struct NewEventGenerator: UIViewControllerRepresentable {
    typealias UIViewControllerType = EKEventEditViewController

    @Binding var isShowing: Bool
    var theEvent: EKEvent

    init(isShowing: Binding<Bool>) {
        eventStore.requestAccess(to: .event) { allow, error in
            print("Result: \(allow) or [\(error.debugDescription)]")
        }

        theEvent = EKEvent.init(eventStore: eventStore)

        _isShowing = isShowing
    }


func makeUIViewController(context: UIViewControllerRepresentableContext<NewEventGenerator>) -> EKEventEditViewController {

    let controller = EKEventEditViewController()
    controller.event = theEvent
    controller.eventStore = eventStore
    controller.editViewDelegate = context.coordinator

    return controller
}

func updateUIViewController(_ uiViewController: NewEventGenerator.UIViewControllerType, context: UIViewControllerRepresentableContext<NewEventGenerator>) {
    uiViewController.view.backgroundColor = .red
}


func makeCoordinator() -> Coordinator {
    return Coordinator(isShowing: $isShowing)
}

class Coordinator : NSObject, UINavigationControllerDelegate, EKEventEditViewDelegate {

    @Binding var isVisible: Bool

    init(isShowing: Binding<Bool>) {
        _isVisible = isShowing
    }

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .canceled:
            isVisible = false
        case .saved:
            do {
                try controller.eventStore.save(controller.event!, span: .thisEvent, commit: true)
            }
            catch {
                print("Event couldn't be created")
            }
            isVisible = false
        case .deleted:
            isVisible = false
        @unknown default:
            isVisible = false
        }
    }
}}
