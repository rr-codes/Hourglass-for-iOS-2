//
//  SearchProvider.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-13.
//

import Foundation
import Combine

/// Binds a specified search query to a sequence of results
/// - Invariant: ``SearchProvider/result`` is always a subset of ``SearchProvider/database``
class SearchProvider<Element>: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var results: [Element] = []
    
    private let database: [Element]
    private let limit: Int
    private let keyPath: (Element) -> String

    /// Searches the database for all entries matching the specified query using _fuzzy_ mtaching
    /// - Note: This is an expensive operation, and should be executed in an asynchronous context
    private func search(_ query: String) -> [Element] {
        database
            .map(keyPath)
            .sortedByFuzzyMatchPattern(query, limit: limit)
            .compactMap { name in database.first(where: { keyPath($0) == name }) }
    }
        
    init(_ database: [Element], limit: Int, keyPath: @escaping (Element) -> String) {
        self.database = database
        self.limit = limit
        self.keyPath = keyPath
        
        let defaultList = Array(self.database.prefix(limit))
        
        $searchQuery
            .debounce(for: .microseconds(5), scheduler: DispatchQueue.main)
            .map { [weak self] query -> AnyPublisher<[Element], Never> in
                if let self = self, !query.isEmpty {
                    return DispatchQueue.global()
                        .deferred { self.search(query) }
                        .eraseToAnyPublisher()
                } else {
                    return Just(defaultList).eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .receive(on: RunLoop.main)
            .assign(to: &$results)
    }
}

extension DispatchQueue {
    /// Asynchronously executes `block` and wraps it in a `Deferred` Publisher
    func deferred<T>(execute work: @escaping () -> T) -> Deferred<Future<T, Never>> {
        Deferred {
            Future { [unowned self] promise in
                async {
                    promise(.success(work()))
                }
            }
        }
    }
}
