//
//  QuotedStringTests.swift
//  StringUtilitiesTests
//
//  Created by Jim Clarke on 2020-11-27.
//

import XCTest
@testable import StringUtilities

class QuotedStringTests: XCTestCase {

    var source: String? = nil
    var start: String.Index? = nil
    var quote: Character = DEFAULT_QUOTE_CHAR

    var str: String?
    var pos: String.Index?

    func testSimple() throws {
        (str, _) = getQuotedString(source: "   \"hi, mom\"")
        XCTAssertEqual(str, "hi, mom")

        (str, _) = getQuotedString(source: #"   "hi, mom""#)
        XCTAssertEqual(str, "hi, mom")
    }
    
    func testSimpleUnquotedIndex() throws {
        source = "hi, mom"
        pos = unquotedIndexOf(source: source, char: ",")
        XCTAssertEqual(pos, source!.index(source!.startIndex, offsetBy: 2))
    }

    
    // Tests from TestQuotedString.java.

    // -- parse from 0 --

    // Test a bunch together. (Corresponds to a loop in the Java test.)
    struct TestCase1 {
        var source: String?
        var startPos: Int?
        var quote: Character
        var outPos: Int?
        var out: String?
        
        init(_ source: String?, _ startPos: Int?, _ quote: Character,
             _ outPos: Int?, _ out: String?) {
            self.source = source
            self.startPos = startPos
            self.quote = quote
            self.outPos = outPos
            self.out = out
        }
    }
    
    let testdata1 = [
        TestCase1(nil, 0, "\"", nil, nil),
        TestCase1("", 0, "\"", nil, nil),
        TestCase1("", 0, "'", nil, nil),
        TestCase1("", 0, "!", nil, nil),
        TestCase1(" ", 0, "!", nil, nil),
        TestCase1(" a", 0, "!", nil, nil),
        TestCase1("!", 0, "!", nil, nil),
        TestCase1(" !", 0, "!", nil, nil),
        TestCase1(" ! ", 0, "!", nil, nil),
        TestCase1("!!", 0, "!", 2, ""),
        TestCase1("!!hi", 0, "!", 2, ""),
        TestCase1("!hi!", 0, "!", 4, "hi"),
            // -- moved from Java version's parseObject
        TestCase1("! hi !there", 0, "!", 6, " hi "),
        TestCase1("! hi there", 0, "!", nil, nil),
        TestCase1(" \\ !hi!there", 0, "!", nil, nil),
        TestCase1(#" \ !hi!there"#, 0, "!", nil, nil),
        TestCase1(" \\! !hi!there", 0, "!", nil, nil),
        TestCase1("  !\\!hi!there", 0, "!", 8, "!hi"),
        TestCase1(#"  !\!hi!there"#, 0, "!", 8, "!hi"),
        TestCase1("  !\\!hi!\\!there", 0, "!", 8, "!hi"),
        TestCase1(#"  !\!hi!\!there"#, 0, "!", 8, "!hi"),
        TestCase1("  !hi\\!there", 0, "!", nil, nil),
        TestCase1(#"  !hi\!there"#, 0, "!", nil, nil),
        TestCase1("  !hi\\!!there", 0, "!", 8, "hi!"),
        TestCase1(#"  !hi\!!there"#, 0, "!", 8, "hi!"),
            // -- same as a test in Java version's parseObject
        TestCase1("  !h\\i!there", 0, "!", 7, "h\\i"),
        TestCase1(#"  !h\i!there"#, 0, "!", 7, #"h\i"#),
        TestCase1("  !hi\\\\!there", 0, "!", 8, "hi\\"),
        TestCase1(#"  !hi\\!there"#, 0, "!", 8, #"hi\"#),
        TestCase1(" \\", 0, "!", nil, nil),
        TestCase1(#" \"#, 0, "!", nil, nil),
        TestCase1(" ! \\", 0, "!", nil, nil),
        TestCase1(#" ! \"#, 0, "!", nil, nil),
        TestCase1("\t!after a tab!", 0, "!", 14, "after a tab"),
    ]

    func testMultiFrom0() {
        for i in 0 ..< testdata1.count {
            let source = testdata1[i].source
            var start : String.Index? = nil
            if testdata1[i].source != nil {
                start = source!.index(source!.startIndex,
                                      offsetBy: testdata1[i].startPos!)
            }
            let quote = testdata1[i].quote
            (str, pos) = getQuotedString(source: source, start: start, quote: quote)
            XCTAssertEqual(str, testdata1[i].out)
            if testdata1[i].outPos == nil || source == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source!.index(source!.startIndex,
                                            offsetBy: testdata1[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }

    // -- parse from nil --
    
    // Same test cases as parse from 0. In the Java version, the last test was
    // omitted here.

    func testMultiFromNil() {
        for i in 0 ..< testdata1.count {
            let source = testdata1[i].source
            let start : String.Index? = nil
            // if testdata1[i].source != nil {
            //     start = source!.index(source!.startIndex,
            //                           offsetBy: testdata1[i].startPos!)
            // }
            let quote = testdata1[i].quote
            (str, pos) = getQuotedString(source: source, start: start, quote: quote)
            XCTAssertEqual(str, testdata1[i].out)
            if testdata1[i].outPos == nil || source == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source!.index(source!.startIndex,
                                            offsetBy: testdata1[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }

    // -- parse from offset --
    let testdata2 = [
         TestCase1("   !hi!there", 2, "!", 7, "hi"),
         TestCase1("   !hi!there", 3, "!", 7, "hi"),
         TestCase1("   !hi!there", 4, "!", nil, nil),
         TestCase1("!hi!there!", 3, "!", 10, "there"),
         TestCase1("x !hi!", 1, "!", 6, "hi"),
    ]

    func testMultiFromOffset() {
        for i in 0 ..< testdata2.count {
            let source = testdata2[i].source
            var start : String.Index? = nil
            if testdata1[i].source != nil {
                start = source!.index(source!.startIndex,
                                      offsetBy: testdata2[i].startPos!)
            }
            let quote = testdata2[i].quote
            (str, pos) = getQuotedString(source: source, start: start, quote: quote)
            XCTAssertEqual(str, testdata2[i].out)
            if testdata2[i].outPos == nil || source == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source!.index(source!.startIndex,
                                            offsetBy: testdata2[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }

    // -- unquotedIndexOf() --
    
    func testUnquotedIndexInNil() throws {
        source = nil
        pos = unquotedIndexOf(source: source, char: "*")
        XCTAssertEqual(pos, nil)
    }

    struct TestCase3 {
            // There is no TestCase2; this is "3" to match the data.
        var source: String
        var char: Character
        var quote: Character
        var outPos: Int?
        
        init(_ source: String, _ char: Character, _ quote: Character,
             _ outPos: Int?) {
            self.source = source
            self.char = char
            self.quote = quote
            self.outPos = outPos
        }
    }
    
    let testdata3 = [
//        TestCase3(nil, "*", "\"", nil), // moved to testUnquotedIndexInNil
        TestCase3(#""#, "*", "\"", nil),
        TestCase3(#"before * after"#, "*", "\"", 7),
        TestCase3(#"* after"#, "*", "\"", 0),
        TestCase3(#" *after"#, "*", "\"", 1),
        TestCase3(#"before"#, "*", "\"", nil),
        TestCase3(#"bef"*"ore"#, "*", "\"", nil),
        TestCase3(#"bef"*"ore * after"#, "*", "\"", 10),
        TestCase3(#"bef"*"ore * aft*er"#, "*", "\"", 10),
        TestCase3(#""*""#, "*", "\"", nil),
        TestCase3(#"bef"*"#, "*", "\"", nil),
        TestCase3(#"bef"\\*"ore * after"#, "*", "\"", 12),
        TestCase3(#"bef"\*"ore * after"#, "*", "\"", 11),
        TestCase3(#"bef"\"#, "*", "\"", nil),
        TestCase3(#"bef \""#, "*", "\"", nil),
        TestCase3(#"bef \"*"#, "*", "\"", nil),
        TestCase3(#"bef "\"*"#, "*", "\"", nil),
        TestCase3(#" "hi!""#, "\"", "\"", 1),
        TestCase3(#" \ "hi!""#, #"\"#, "\"", 1),
    ]

    func testMultiChar() {
        for i in 0 ..< testdata3.count {
            let source = testdata3[i].source
            let char = testdata3[i].char
            let quote = testdata3[i].quote
            let pos = unquotedIndexOf(source: source, char: char, quote: quote)
            if testdata3[i].outPos == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source.index(source.startIndex,
                                            offsetBy: testdata3[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }


}
