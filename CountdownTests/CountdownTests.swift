//
//  CountdownTests.swift
//  CountdownTests
//
//  Created by Richard Robinson on 2020-07-31.
//

import XCTest
@testable import Countdown

extension Sequence where Element: Hashable {
    /// Returns an array containing all the elements of this Sequence, with no duplicate elements
    func distinct() -> [Element] {
        var set: Set<Element> = []
        return filter { set.insert($0).inserted }
    }
}

class CountdownTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUniqueSequence() throws {
        let array = [1, 2, 3, 2, 3, 3, 4, 4, 5, 6, 5, 7]
        let unique = array.distinct()
        
        XCTAssertEqual([1, 2, 3, 4, 5, 6, 7], unique)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
