import XCTest
@testable import StringUtilities

final class StringUtilitiesTests: XCTestCase {
    // func testExample() {
    //     // This is an example of a functional test case.
    //     // Use XCTAssert and related functions to verify your tests produce the correct
    //     // results.
    //     XCTAssertEqual(StringUtilities().text, "Hello, World!")
    // }

    // static var allTests = [
    //     ("testExample", testExample),
    // ]

    var source: String = ""
    var pos: String.Index?
        
    func testSimple() {
        source = "   hi"
        pos = skipWhitespace(source)
        XCTAssertEqual(pos, source.index(source.startIndex, offsetBy: 3))
    }
    
}

