//
//  SearchService.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 17/08/26.
//

import Foundation
import Combine

class SearchService: SearchServiceProtocol {
    func search(query: String) -> AnyPublisher<[SearchResult], Error> {
        guard let url = URL(string: "http://api.com/search?q=\(query)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SearchResult].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
