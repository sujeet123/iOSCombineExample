//
//  SearchViewModel.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 18/08/26.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var results: [SearchResult] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let searchService: SearchServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(searchService: SearchServiceProtocol = SearchService()) {
        self.searchService = searchService
    }
    
    private func bindSearch() {
        $query.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .flatMap {
                [weak self] query -> AnyPublisher<[SearchResult], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                self.isLoading = true
                self.errorMessage = nil
                
                return self.searchService.search(query: query)
                    .catch { [weak self] error -> AnyPublisher<[SearchResult], Never> in
                                            self?.errorMessage = "Search failed. Try again."
                                            return Just([]).eraseToAnyPublisher()
                                        }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] results in
                                self?.isLoading = false
                                self?.results = results
            }
            .store(in: &cancellables)
        
        // Clear results when query becomes empty
        $query
            .filter { $0.trimmingCharacters(in: .whitespaces).isEmpty }
            .sink { [weak self] _ in
                self?.results = []
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}
