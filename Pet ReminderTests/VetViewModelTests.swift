//
//  VetViewModelTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 24.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import XCTest
@testable import Pet_Reminder

final class VetViewModelTests: XCTestCase {
    
    func testPinSearch() async throws {
        let viewModel = VetViewModel()
        viewModel.searchText = "Vet"
        await viewModel.searchPins()
        XCTAssertTrue(viewModel.searchedLocations.isNotEmpty)
    }
    
    func testClearSearchedLocations() async throws {
        let viewModel = VetViewModel()
        viewModel.searchText = "Pet"
        await viewModel.searchPins()
                
        await viewModel.clearPreviousSearches()
        
        Task {
            let halfSecond = UInt64(0.5 * 1_000_000_000)
            try await Task.sleep(nanoseconds: halfSecond)
            XCTAssertTrue(viewModel.searchedLocations.isEmpty)
            
        }
    }
    
    func testAuthenticationStatus() async throws {
        let viewModel = VetViewModel()
        await viewModel.requestMap()
        
        XCTAssertTrue(viewModel.mapViewStatus == .authorized)
    }
    
}
