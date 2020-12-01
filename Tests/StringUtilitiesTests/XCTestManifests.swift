import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StringUtilitiesTests.allTests),
        testCase(BracketedStringTests.allTests),
        testCase(ApplyRegexTests.allTests),
        testCase(WhitespaceTests.allTests),
        testCase(QuotedStringTests.allTests),
    ]
}
#endif
