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
    
    func testCheck() {
        XCTAssertFalse(Name.check(name: "jim!"))
        XCTAssert(Name.check(name: "jim"))
        XCTAssert(Name.check(name: ""))
    }
    
    let standardizeTests = [
        ["jim!", "jim!"],
        ["  hi my.  name is,jim, ", "hi my. name is jim"],
        ["h\ti", "h i"],
        ["\ttab\t2tabs\t\tendtabs\t\t\t", "tab 2tabs endtabs"],
        [",ab,,cd,, ,ef,, ,", "ab cd ef"],
    ]
    
    func testStandardize() {
        for i in 0 ..< standardizeTests.count {
            let before = standardizeTests[i][0]
            let after = Name.standardize(name: before)
            let shouldbe = standardizeTests[i][1]
            XCTAssertEqual(after, shouldbe)
        }
    }
}
