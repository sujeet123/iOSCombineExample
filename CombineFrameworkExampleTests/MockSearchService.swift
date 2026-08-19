//
//  MockSearchService.swift
//  CombineFrameworkExampleTests
//
//  Created by Sujeet kumar on 19/08/26.
//

import Foundation
import Combine
import XCTest
@testable import CombineFrameworkExample

class MockSearchService: XCTestCase,SearchServiceProtocol {
    var searchCallCount = 0
    
    func search(query: String) -> AnyPublisher<[SearchResult], any Error> {
        searchCallCount += 1
        let result = [SearchResult(id: 1, title: "Result for \(query)")]
        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
    //Test: Rapid typing should trigger one api call only
    func testDebouncrFireOnlyOnce() {
        let mockService = MockSearchService()
        let viewModel = SearchViewModel(searchService: mockService)
        viewModel.query = "s"
        viewModel.query = "sw"
        viewModel.query = "Swi"
        viewModel.query = "Swif"
        viewModel.query = "Swift"
        //let expectation = expectation(description: "debounce settles")
        let debounceExpectation = expectation(description: "debounce settles")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            XCTAssertEqual(mockService.searchCallCount, 1)
            debounceExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
