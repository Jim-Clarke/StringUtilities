//
//  WhitespaceTests.swift
//  StringUtilitiesTests
//
//  Created by Jim Clarke on 2020-11-21.
//

import XCTest
@testable import StringUtilities

class WhitespaceTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    // Testing padding.
    
    func testSimpleNChars() {
        XCTAssertEqual(nChars(-2), "")
        XCTAssertEqual(nChars(-1), "")
        XCTAssertEqual(nChars(0), "")
        XCTAssertEqual(nChars(1), " ")
        XCTAssertEqual(nChars(2), "  ")
        XCTAssertEqual(nChars(3), "   ")
    }

    func testOneNChars() {
        XCTAssertEqual(nChars(1, char: "j"), "j")
    }
    
    func testNegativeNChars() {
        XCTAssertEqual(nChars(-12), "")
    }
    
    func testNBlanks() {
        XCTAssertEqual(nBlanks(-1), "")
        XCTAssertEqual(nBlanks(0), "")
        XCTAssertEqual(nBlanks(1), " ")
        XCTAssertEqual(nBlanks(3), "   ")
    }

    // Tests from TestWhiteSpace.java (where the tests are for format()).

    func testLeftPadding() {
        XCTAssertEqual(leftPadded("hi", desiredCount: 5), "   hi")
        XCTAssertEqual(leftPadded("hi", desiredCount: 2), "hi")
        XCTAssertEqual(leftPadded("hi", desiredCount: 0), "hi")
        XCTAssertEqual(leftPadded("hi", desiredCount: -1), "hi")
        XCTAssertEqual(leftPadded("", desiredCount: 5), "     ")
        XCTAssertEqual(leftPadded("", desiredCount: 0), "")
        XCTAssertEqual(leftPadded("", desiredCount: -1), "")
    }

    func testRightPadding() {
        XCTAssertEqual(rightPadded("hi", desiredCount: 5), "hi   ")
        XCTAssertEqual(rightPadded("hi", desiredCount: 2), "hi")
        XCTAssertEqual(rightPadded("hi", desiredCount: 0), "hi")
        XCTAssertEqual(rightPadded("hi", desiredCount: -1), "hi")
        XCTAssertEqual(rightPadded("", desiredCount: 5), "     ")
        XCTAssertEqual(rightPadded("", desiredCount: 0), "")
        XCTAssertEqual(rightPadded("", desiredCount: -1), "")
    }

    
    // Testing scanning.
    
    var source: String = ""
    var start: String.Index?
    var pos: String.Index?
    var number: Double?
        
    func testSimple() {
        source = "   hi"
        pos = skipWhitespace(source)
        XCTAssertEqual(pos, source.index(source.startIndex, offsetBy: 3))
    }
    
    func testEmpty() {
        source = ""
        pos = skipWhitespace(source)
        XCTAssertEqual(pos, source.startIndex)
        XCTAssertEqual(pos, source.endIndex)
        XCTAssertNotNil(pos)
    }
    
    func testWithOffset() {
        source = "   hi"
        start = source.index(after: source.startIndex)
        pos = skipWhitespace(source, start: start)
        XCTAssertEqual(pos, source.index(source.startIndex, offsetBy: 3))
    }
    
    func testTrimWhitespace() {
        XCTAssertEqual(trimWhitespace(" hi, mom   "), "hi, mom")
        XCTAssertEqual(trimWhitespace("hi, mom   "), "hi, mom")
        XCTAssertEqual(trimWhitespace(" hi, mom"), "hi, mom")
        XCTAssertEqual(trimWhitespace("hi, mom"), "hi, mom")
        XCTAssertEqual(trimWhitespace(" hi, mom \t  "), "hi, mom")
        XCTAssertEqual(trimWhitespace("    \t  \t   "), "")
        XCTAssertEqual(trimWhitespace(""), "")
    }

    // Tests from TestWhiteSpace.java (where the tests are for parse()).

    // Java: -- parse(full, 0) -- AND -- parse(full, null tail) --
    // Test a bunch together. (Corresponds to a loop in the Java test.)
    
    struct TestCase1 {
        var source: String
        var out: String?
        var outPos: Int?
        
        init(_ source: String, _ out: String?, _ outPos: Int?) {
            self.source = source
            self.out = out
            self.outPos = outPos
        }
    }
    
    let testdata1 = [
        // The second elements are not used in the tests. We might need
        // them in tests of functions that don't exist yet.
        TestCase1("a", "a", 0),
        TestCase1(" b", "b", 1),
        TestCase1("  c ", "c ", 2),
        TestCase1("   d", "d", 3),
        TestCase1("", "", 0),
        TestCase1(" ", "", 1),
        TestCase1("  ", "", 2),
        TestCase1("   ", "", 3),
        TestCase1("\thi\t", "hi\t", 1),
        TestCase1("\t there", "there", 2),
        
        // extra cases from Java: -- parseObject() --
        // which is effectively the same as above (exactly the same, in two
        // cases)
        TestCase1("", "", 0),
        TestCase1("\t", "", 1),
        TestCase1(" hi ", "hi ", 1),
        TestCase1("\t there", "there", 2),
    ]

    func testMultiFrom0AndNil() {
        for i in 0 ..< testdata1.count {
            source = testdata1[i].source
            let expectedPos = source.index(source.startIndex,
                                           offsetBy: testdata1[i].outPos!)
            start = source.startIndex
            pos = skipWhitespace(source, start: start)
            XCTAssertEqual(pos, expectedPos)

            pos = skipWhitespace(source)
            XCTAssertEqual(pos, expectedPos)
        }
    }
    
    // Java: -- parse(full, offset) --

    struct TestCase2 {
        var source: String
        var start: Int
        var outPos: Int?
        
        init(_ source: String, _ start: Int, _ outPos: Int?) {
            self.source = source
            self.start = start
            self.outPos = outPos
        }
    }
    
    let testdata2 = [
        // Some test cases from the Java version can't be used because
        // the starting index would be out of bounds. See testTooLargeStarts
        // for an example.
        TestCase2("", 0, 0),
//        TestCase2("", 1, nil),
//        TestCase2("", 2, nil),
//        TestCase2("", -1, nil), // starting index out of bounds
        TestCase2(" ", 0, 1),
        TestCase2(" ", 1, 1),
//        TestCase2(" ", 2, nil), // starting index out of bounds
//        TestCase2(" ", 3, nil), // starting index out of bounds
//        TestCase2(" ", -1, nil), // starting index out of bounds
        TestCase2(" a b  c", 0, 1),
        TestCase2(" a b  c", 1, 1),
        TestCase2(" a b  c", 2, 3),
        TestCase2(" a b  c", 3, 3),
        TestCase2(" a b  c", 4, 6),
        TestCase2(" a b  c", 5, 6),
        TestCase2(" a b  c", 6, 6),
        TestCase2(" a b  c", 7, 7),
//        TestCase2(" a b  c", 8, nil), // starting index out of bounds
//        TestCase2(" a b  c", -1, nil), // starting index out of bounds
        TestCase2("hi\tthere", 2, 3),
    ]

    func testMultiFromOffset() {
        for i in 0 ..< testdata2.count {
            source = testdata2[i].source
            start = source.index(source.startIndex,
                                       offsetBy: testdata2[i].start)
            var expectedPos: String.Index? = nil
            if testdata2[i].outPos != nil {
                expectedPos = source.index(source.startIndex,
                                           offsetBy: testdata2[i].outPos!)
            }
            pos = skipWhitespace(source, start: start)
            XCTAssertEqual(pos, expectedPos)
        }
    }
    
    func testTooLargeStarts() {
        source = "short"
        start = source.endIndex
        XCTAssertEqual(skipWhitespace(source, start: start), source.endIndex)
        
        start = "veryverylong".endIndex
        XCTAssertNil(skipWhitespace(source, start: start))
    }

    // Java: -- parse() --

    struct TestCase3 {
        var source: String
        var outCount: Int
        
        init(_ source: String, _ outCount: Int) {
            self.source = source
            self.outCount = outCount
        }
    }
    
    let testdata3 = [
        TestCase3("", 0),
        TestCase3("\t", 1),
        TestCase3(" ", 1),
        TestCase3(" \t", 2),
        TestCase3("\t ", 2),
        TestCase3("\t\t\t", 3),
        TestCase3("hi", 0),
        TestCase3(" hi", 1),
        TestCase3("\thi", 1),
        TestCase3(" \t hi ", 3),
    ]

    // "Plain parse" is just skipWhitespace, but OK.
    func testPlainParse() {
        for i in 0 ..< testdata3.count {
            source = testdata3[i].source
            let expectedPos = source.index(source.startIndex,
                                       offsetBy: testdata3[i].outCount)
            pos = skipWhitespace(source)
            XCTAssertEqual(pos, expectedPos)
        }
    }

    // -- chaining --
    // That is, scan past blanks so as to get to a string interpretable as a
    // number. Tests are based on tests in TestWhiteSpace.java.

    func testChaining() {
        source = "1.234"
        number = Double(source)
        XCTAssertEqual(number, 1.234)
        
        source = "   1.234"
        number = Double(source)
        XCTAssertEqual(number, nil)
        
        number = Double(source[skipWhitespace(source)! ..< source.endIndex])
        XCTAssertEqual(number, 1.234)
        
        number = Double(trimWhitespace(source))
        XCTAssertEqual(number, 1.234)
 
        source = "1.234  "
        number = Double(source)
        XCTAssertEqual(number, nil)
        number = Double(trimWhitespace(source))
        XCTAssertEqual(number, 1.234)

        source = "   1.234     "
        number = Double(trimWhitespace(source))
        XCTAssertEqual(number, 1.234)
    }
}
