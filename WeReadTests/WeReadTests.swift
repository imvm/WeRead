//
//  WeReadTests.swift
//  WeReadTests
//
//  Created by Ian Manor on 06/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import XCTest
@testable import WeRead

class WeReadTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let arrayWithDuplicates = [5, 1, 2, 3 , 4, 1, 1, 1, 2, 5]
        let arrayWithoutDuplicates = [1, 2, 3, 4, 5]
        
        let arrayRemovingDuplicates = arrayWithDuplicates.removingDuplicates()
        
        XCTAssertEqual(arrayRemovingDuplicates.sorted(), arrayWithoutDuplicates.sorted())
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
