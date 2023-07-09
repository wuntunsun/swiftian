//
//  swiftianTests.swift
//  swiftianTests
//
//  Created by Robert Norris on 11.06.23.
//

import XCTest
@testable import swiftian

class swiftianTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllTheTropes() throws {

        let expectation = self.expectation(description: #function)
        
        let allTheTropes = AllTheTropes()
        allTheTropes.tropes { tropes in
            
            guard !tropes.isEmpty else {
                
                XCTFail()
                return
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
