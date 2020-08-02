//
//  CountdownTests.swift
//  CountdownTests
//
//  Created by Richard Robinson on 2020-07-31.
//

import XCTest
@testable import Countdown

class CountdownTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEmojiProvider() throws {
        let contents = """
        [
          [
            {
              "emoji":"😀",
              "name":"grinning_face"
            },
            {
              "emoji":"😃",
              "name":"grinning_face_with_big_eyes"
            }
          ]
        ]
        """
        
        let provider = EmojiDBProvider(from: contents)
        XCTAssertEqual(provider.database.first!.first!.emoji, "😀")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
