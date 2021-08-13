//
//  NameTests.swift
//  
//
//  Created by Jim Clarke on 2021-07-30.
//

import XCTest
@testable import StringUtilities

class NameTests: XCTestCase {
    func testTesting() {
        let str = Name.testing()
        XCTAssertEqual(str, "hi, mom")
    }
    
    func testInit() {
        let me = Name(name: "Jim")
        XCTAssertEqual(me.name, "Jim")
    }
}
