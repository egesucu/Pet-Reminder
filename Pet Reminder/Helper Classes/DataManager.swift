//
//  DataManager.swift
//  DataManager
//
//  Created by Ege Sucu on 11.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import CloudKit


class DataManager{
    
    static let shared = DataManager()
    
    func checkIcloudAvailability(completion: @escaping (IcloudResult) -> Void){
        
        CKContainer.default().accountStatus { status, error in
            guard error == nil else { completion(.error(.unknownError(error!.localizedDescription))) ; return }
            
            switch status{
            case .available:
                completion(.success)
            case .noAccount:
                completion(.error(.noIcloud))
            case .restricted:
                completion(.error(.restricted))
            case .couldNotDetermine:
                completion(.error(.icloudUnavailable))
            case .temporarilyUnavailable:
                completion(.error(.icloudUnavailable))
            @unknown default:
                completion(.error(.unknownError(error?.localizedDescription ?? "")))
            }
        }
    }
    
}
