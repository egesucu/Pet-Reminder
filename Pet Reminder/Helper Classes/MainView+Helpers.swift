//
//  MainView+Helpers.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import CloudKit

extension MainView{
    func checkData(completion: @escaping (Result<Bool,IcloudError>) -> Void){
        
        var isIcloudAvailable = false
        
        CKContainer.default().accountStatus { status, error in
            if let error = error {
                completion(.failure(.unknownError(error.localizedDescription)))
            }
            
            switch status{
            case .available:
                isIcloudAvailable = true
                break
            case .noAccount:
                completion(.failure(.noIcloud))
            case .restricted:
                completion(.failure(.restricted))
            case .couldNotDetermine:
                completion(.failure(.icloudUnavailable))
            case .temporarilyUnavailable:
                completion(.failure(.icloudUnavailable))
            @unknown default:
                completion(.failure(.unknownError(error?.localizedDescription ?? "")))
            }
        }
        
        if isIcloudAvailable{
            if NSUbiquitousKeyValueStore.default.bool(forKey: "petSaved"){
                completion(.success(true))
            } else {
                completion(.failure(.unknownError("")))
            }
        } else {
            completion(.failure(.unknownError("iCloud is not enabled.")))
        }
    }
}
