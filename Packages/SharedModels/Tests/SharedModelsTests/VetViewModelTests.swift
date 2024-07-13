//
//  VetViewModelTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 24.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Testing
import Observation
import OSLog
@testable import SharedModels

@Suite("Vet ViewModel Tests") struct VetViewModelTests {

    @Test @MainActor func testPinSearch() async throws {
        let viewModel = VetViewModel()
        viewModel.searchText = "Vet"
        
        try await viewModel.searchPins()
        
        Task {
            let halfSecond: Duration = .milliseconds(500)
            try await Task.sleep(for: halfSecond)
            #expect(viewModel.searchedLocations.isNotEmpty)
        }
    }

    
    @Test @MainActor func testClearSearchedLocations() async throws {
        let viewModel = VetViewModel()
        viewModel.searchText = "Pet"
        do {
            try await viewModel.searchPins()
        } catch let error {
            Issue.record(error, "Error setting user location")
        }

        await viewModel.clearPreviousSearches()

        Task {
            let halfSecond: Duration = .milliseconds(500)
            try await Task.sleep(for: halfSecond)
            #expect(viewModel.searchedLocations.isEmpty)
        }
    }
}
