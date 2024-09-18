//
//  PetManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.06.2024.
//  Copyright © 2024 Ege Sucu. All rights reserved.
//
import Foundation

actor PetManager {
    private var pet: Pet
    
    init(pet: Pet) {
        self.pet = pet
    }
    
    func convertIntoSelection(choice: Int) -> FeedSelection {
        if pet.feedSelection == nil {
            return switch choice {
            case 0:
                    .morning
            case 1:
                    .evening
            default:
                    .both
            }
        } else {
            return pet.feedSelection ?? .both
        }
    }
    
    func updateName(name: String) {
        pet.name = name
    }
    
    func updateBirthday(birthday: Date) {
        pet.birthday = birthday
    }
    
    func addFeed(feed: Feed) {
        pet.feeds?.append(feed)
    }
    
    func addVaccine(vaccine: Vaccine) {
        pet.vaccines?.append(vaccine)
    }
    
    func removeFeed(feed: Feed) {
        guard let feeds = pet.feeds else { return }
        if let index = feeds.firstIndex(of: feed) {
            pet.feeds?.remove(at: index)
        }
    }
    
    func removeVaccine(vaccine: Vaccine) {
        guard let vaccines = pet.vaccines else { return }
        if let index = vaccines.firstIndex(of: vaccine) {
            pet.vaccines?.remove(at: index)
        }
    }
    
    func updateFeedSelection(feedSelection: FeedSelection) {
        pet.feedSelection = feedSelection
    }
    
    func getPet() -> Pet {
        return pet
    }
}
