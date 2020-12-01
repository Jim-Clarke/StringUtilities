//
//  ApplyRegexTests.swift
//  ApplyRegexTests
//
//  Created by Jim Clarke on 2020-11-19.
//

import XCTest
@testable import StringUtilities

class ApplyRegexTests: XCTestCase {

    var regex: String = ""
    var target: String = ""
    var result = [[String]]()
    
    func testSimple() {
        regex = #"[a-z]{2}, [a-z]*"#
        target = "(hi, mom)"
        result = applyRegex(regex: regex, target: target)
        XCTAssertEqual(result, [["hi, mom"]])
    }
 
    // Test a bunch together. (Corresponds to a loop in the Java test.)
    struct TestCase1 {
        var regex: String
        var target: String
        var result: [[String]]
        
        init(_ regex: String, _ target: String, _ result: [[String]]) {
            self.regex = regex
            self.target = target
            self.result = result
        }
    }

    let testdata1 = [
        TestCase1(#"Z"#, "hi, mom", []),
        TestCase1(#"(a+) home (\d+)"#, "hi, mom, I'm aa home 567 times",
                  [["aa home 567", "aa", "567"]]),
        TestCase1(#"(a+) home (\d+)"#,
                  "hi, mom, I'm aa home 567 times\n and dad aaa home 42",
                  [["aa home 567", "aa", "567"], ["aaa home 42", "aaa", "42"]]),
        ]

    func testMulti() {
        for i in 0 ..< testdata1.count {
            let regex = testdata1[i].regex
            let target = testdata1[i].target
            let expected = testdata1[i].result
            let result = applyRegex(regex: regex, target: target)
            XCTAssertEqual(result, expected)
        }
    }

}
