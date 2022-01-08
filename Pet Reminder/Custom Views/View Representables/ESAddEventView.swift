//
//  ESAddEventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.01.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import SwiftUI
import EventKitUI


struct ESAddEventView: UIViewControllerRepresentable{
    
    typealias UIViewControllerType = EKEventEditViewController
    
    @Binding var shouldDismiss: Bool
    @StateObject var eventManager = EventManager()
    @Environment(\.presentationMode) var presentationMode
    let feedback = UINotificationFeedbackGenerator()
    
    class Coordinator: NSObject,EKEventEditViewDelegate,UINavigationControllerDelegate{
        var parent: ESAddEventView
        var eventManager: EventManager
        
        init(_ parent: ESAddEventView,_ eventManager: EventManager){
            self.parent = parent
            self.eventManager = eventManager
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            if action == .saved{
                parent.eventSavedAction()
            } else if action == .canceled{
                parent.eventCancelledAction()
            }
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self,eventManager)
    }
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventCoordinator = EKEventEditViewController()
        eventCoordinator.eventStore = eventManager.eventStore
        eventCoordinator.delegate = context.coordinator
        eventCoordinator.editViewDelegate = context.coordinator
        return eventCoordinator
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        
    }
    
    func eventSavedAction(){
        feedback.notificationOccurred(.success)
        presentationMode.wrappedValue.dismiss()
    }
    
    func eventCancelledAction(){
        feedback.notificationOccurred(.error)
        presentationMode.wrappedValue.dismiss()
    }
    
    
    
}
