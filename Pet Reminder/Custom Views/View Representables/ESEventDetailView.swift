//
//  ESEventDetailView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 3.01.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import EventKitUI
import SwiftUI

struct ESEventDetailView: UIViewControllerRepresentable {

  typealias UIViewControllerType = EKEventViewController

  class Coordinator: NSObject, EKEventViewDelegate {

    // MARK: Lifecycle

    init(_ parent: ESEventDetailView) {
      self.parent = parent
    }

    // MARK: Internal

    var parent: ESEventDetailView

    func eventViewController(_ controller: EKEventViewController, didCompleteWith _: EKEventViewAction) {
      controller.dismiss(animated: true, completion: nil)
    }

  }

  var event: EKEvent

  func makeUIViewController(context: Context) -> EKEventViewController {
    let view = EKEventViewController()
    view.event = event
    view.allowsEditing = true
    view.allowsCalendarPreview = true
    view.delegate = context.coordinator
    return view
  }

  func updateUIViewController(_: EKEventViewController, context _: Context) { }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

}
