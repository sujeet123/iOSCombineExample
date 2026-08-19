//
//   SearchResult.swift
//  CombineFrameworkExample
//
//  Created by Sujeet kumar on 17/08/26.
//

import Foundation
import Combine

struct SearchResult: Decodable, Identifiable {
    let id: Int
    let title: String
}

protocol SearchServiceProtocol {
    func search(query: String) -> AnyPublisher<[SearchResult], Error>
}
