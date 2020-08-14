//
//  SearchProvider.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-13.
//

import Foundation
import Combine

class SearchProvider<DB: Database>: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var result: [DB.Item] = []
    
    private let database: DB

    private func search(_ query: String) -> [DB.Item] {
        let flat = database.all

        return flat
            .map(\.description)
            .sortedByFuzzyMatchPattern(query, limit: database.limit)
            .compactMap { name in flat.first(where: { $0.description == name }) }
    }
    
    init(database: DB) {
        self.database = database
        self.result = Array(self.database.all.prefix(self.database.limit))

        $searchQuery
            .debounce(for: .microseconds(5), scheduler: DispatchQueue.main)
            .flatMap { [unowned self] query in
                DispatchQueue.global().deferred { search(query) }
            }
            .receive(on: RunLoop.main)
            .assign(to: &$result)
    }
}


protocol Database {
    associatedtype Item: CustomStringConvertible
        
    var all: [Item] { get }
    
    var limit: Int { get }
}

extension DispatchQueue {
    /// Asynchronously executes `block` and wraps it in a `Deferred` Publisher
    func deferred<T>(execute work: @escaping () -> T) -> AnyPublisher<T, Never> {
        Deferred {
            Future { [unowned self] promise in
                async {
                    promise(.success(work()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
