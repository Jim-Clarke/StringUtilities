//
//  GetBracketedStringTests.swift
//  GetBracketedStringTests
//
//  Created by Jim Clarke on 2020-11-15.
//

import XCTest
@testable import StringUtilities

class BracketedStringTests: XCTestCase {

    var source: String? = nil
    var start: String.Index? = nil
    var leftBracket: Character = DEFAULT_LEFT_BRACKET
    var rightBracket: Character = DEFAULT_RIGHT_BRACKET
    var quote: Character = DEFAULT_QUOTE_CHAR

    var str: String?
    var pos: String.Index?
    
    // Tests written after "finishing" Swift getBracketedString().
        
    func testSimple() {
        (str, _) = getBracketedString(source: "(hi, mom)")
        XCTAssertEqual(str, "hi, mom")
    }
    
    func testWithWhitespaceAndTrailer() {
        source = "  (hi, mom)and dad"
        (str, pos) = getBracketedString(source: source)
        XCTAssertEqual(str, "hi, mom")
        XCTAssertEqual(source![pos!..<source!.endIndex], "and dad")
    }
    
    func testWithSillyBrackets() {
        source = "  Phi, momQand dad"
        (str, pos) = getBracketedString(source: source,
                                        leftBracket: "P", rightBracket: "Q")
        XCTAssertEqual(str, "hi, mom")
        XCTAssertEqual(source![pos!..<source!.endIndex], "and dad")
    }
    
    // Tests from TestBracketedString.java.
    
    // -- parse from 0 --
    //
    // That is, tests with "start" set to source.startIndex (parsePosition == 0
    // if this were Java).
    
    func testParseFrom01() {
        let source = "(hi \"boo)\" there)"
        let start = source.startIndex
        (str, pos) = getBracketedString(source: source, start: start)
        XCTAssertEqual(str, "hi \"boo)\" there")
        XCTAssertEqual(source[pos!..<source.endIndex], "")
    }
    
    func testParseFrom02() {
        let source = ""
        let start = source.startIndex
        (str, pos) = getBracketedString(source: source, start: start)
        XCTAssertEqual(str, nil)
        XCTAssertEqual(pos, nil)
    }
    
    func testParseFrom03() {
        let source = "  (hi)"
        let start = source.startIndex
        (str, pos) = getBracketedString(source: source, start: start)
        XCTAssertEqual(str, "hi")
        XCTAssertEqual(source[pos!..<source.endIndex], "")
    }
    
    func testParseFrom04() {
        let source = "  [go ) !]! away] there"
        let start = source.startIndex
        (str, pos) = getBracketedString(source: source, start: start,
                                        leftBracket: "[", rightBracket: "]", quote: "!")
        XCTAssertEqual(str, "go ) !]! away")
        XCTAssertEqual(source[pos!..<source.endIndex], " there")
        // same thing, another way
        XCTAssertEqual(pos, source.index(source.startIndex, offsetBy: 17))
    }
    
    func testParseFrom05() {
        let source: String? = nil
        // Can't have non-nil start: this isn't Java.
        (str, pos) = getBracketedString(source: source, quote: "!")
        XCTAssertNil(str)
        XCTAssertNil(pos)
    }
    
    func testParseFrom06() {
        let source: String = ""
        let start = source.startIndex
        (str, pos) = getBracketedString(source: source, start: start, quote: "!")
        XCTAssertNil(str)
        XCTAssertNil(pos)
    }

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
    
    let testdata1: [TestCase1] = [
        TestCase1(" ", nil, nil),
        TestCase1(" a", nil, nil),
        TestCase1(" (a", nil, nil),
        TestCase1("(", nil, nil),
        TestCase1(")", nil, nil),
        TestCase1(" (", nil, nil),
        TestCase1("()", "", 2),
        TestCase1("()hi", "", 2),
        TestCase1("( hi )there", " hi ", 6),
        TestCase1("( (hi) there", nil, nil),
        TestCase1(" \\ (hi)there", nil, nil),
        TestCase1(#" \ (hi)there"#, nil, nil),
        TestCase1(" \\( (hi)there", nil, nil),
        TestCase1(#" \( (hi)there"#, nil, nil),
        TestCase1("  (hi\\)there", "hi\\", 7),
        TestCase1(#"  (hi\)there"#, #"hi\"#, 7),
        TestCase1("  (\\(hi)there", nil, nil),
        TestCase1(#"  (\(hi)there"#, nil, nil),
        TestCase1("  (h\\)i)there", "h\\", 6),
        TestCase1(#"  (h\)i)there"#, #"h\"#, 6),
        TestCase1("  (hi)\\)there", "hi", 6),
        TestCase1(#"  (hi)\)there"#, "hi", 6),
        TestCase1("  (h\\i)there", "h\\i", 7),
        TestCase1(#"  (h\i)there"#, #"h\i"#, 7),
        TestCase1("  (hi\\\\)there", "hi\\\\", 8),
        TestCase1(#"  (hi\\)there"#, #"hi\\"#, 8),
        TestCase1(" ( !)!hi", nil, nil),
        TestCase1(" ( !)! )hi", " !)! ", 8),
        TestCase1(" ( !)\\! )hi", nil, nil),
        TestCase1(#" ( !)\! )hi"#, nil, nil),
        TestCase1(" ( !)\\! )hi\\", nil, nil),
        TestCase1(#" ( !)\! )hi\"#, nil, nil),
        TestCase1(" (\\", nil, nil),
        TestCase1(#" (\"#, nil, nil),
        TestCase1(" \\", nil, nil),
        TestCase1(#" \"#, nil, nil),
        TestCase1(" ( ! \\\\!)hi", " ! \\\\!", 9),
        TestCase1(#" ( ! \\!)hi"#, #" ! \\!"#, 9),
        TestCase1(" ( ! \\! !)hi", " ! \\! !", 10),
        TestCase1(#" ( ! \! !)hi"#, #" ! \! !"#, 10),
        TestCase1("\t(after a tab)", "after a tab", 14),
        TestCase1("!!(a)!", nil, nil),
        TestCase1("(a)!", "a", 3),
        // The next two tests were listed with parseObject() in the Java
        // version.
        TestCase1("(hi)", "hi", 4),
        TestCase1("  (hi!)!)there", "hi!)!", 9),
    ]

    func testMultiFrom0() {
        for i in 0 ..< testdata1.count {
            let source = testdata1[i].source
            let start = source.startIndex
            (str, pos) = getBracketedString(source: source, start: start, quote: "!")
            XCTAssertEqual(str, testdata1[i].out)
            if testdata1[i].outPos == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source.index(source.startIndex,
                                            offsetBy: testdata1[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }
    
    // -- parse from 0 with null start --

    // For some reason, the equivalent test in Java omits the last two cases
    // in testdata1. They should work all the same, so here I'm leaving them in.
    func testMultiFromNull() {
        for i in 0 ..< testdata1.count {
            let source = testdata1[i].source
            let start: String.Index? = nil
            (str, pos) = getBracketedString(source: source, start: start, quote: "!")
            XCTAssertEqual(str, testdata1[i].out)
            if testdata1[i].outPos == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source.index(source.startIndex,
                                            offsetBy: testdata1[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }

    // -- parse from offset --

    // Test a bunch together starting from an offset.
    struct TestCase2 {
        var source: String
        var startPos: Int
        var out: String?
        var outPos: Int?
        
        init(_ source: String, _ startPos: Int, _ out: String?, _ outPos: Int?) {
            self.source = source
            self.startPos = startPos
            self.out = out
            self.outPos = outPos
        }
    }

    let testdata2 = [
        TestCase2("   (hi)there", 2, "hi", 7),
        TestCase2("   (hi)there", 3, "hi", 7),
        TestCase2("   (hi)there", 4, nil, nil),
        TestCase2("(hi(there)", 3, "there", 10),
        TestCase2("x (hi)", 1, "hi", 6),
        TestCase2("(((a) b (c)) d) e)", 0, "((a) b (c)) d", 15),
        TestCase2("(((a) b (c)) d) e)", 1, "(a) b (c)", 12),
    ]

    // // Feb 25/21: found the tests in testdata2 without a corresponding test
    // function. That might very well have been OK, since I was careful setting
    // up the test cases in Nov/20, but it might also have been an oversight --
    // especially since I can't find the same tests duplicated in an earlier
    // collection. So here we go again.
    func testMultiFromOffset() {
        for i in 0 ..< testdata2.count {
            let source = testdata2[i].source
            let start = source.index(source.startIndex,
                                            offsetBy: testdata2[i].startPos)
            (str, pos) = getBracketedString(source: source, start: start)
            XCTAssertEqual(str, testdata2[i].out)
            if testdata2[i].outPos == nil {
                XCTAssertNil(pos)
            }
            else {
                let expectedIndex = source.index(source.startIndex,
                                            offsetBy: testdata2[i].outPos!)
                XCTAssertEqual(pos, expectedIndex)
            }
        }
    }


    // -- parseObject() -- Well, not really: there's no such thing.
    // But we'll do the two test cases just for fun.
    // Moved: see end of testdata1 collection.
    
}
