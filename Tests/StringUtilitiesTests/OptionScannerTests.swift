import XCTest
@testable import StringUtilities

extension OptionError: Equatable {

    // An explicit == function to replace the one provided. I don't want
    // to compare the error messages for exact equality, because if the tests
    // failed every time a message changed, I'd get tired of fixing tests.
    // So this implementation of Equatable checks that the shorter "error
    // message" -- presumably as specified in the test case -- is contained in
    // the actual error message produced by the code that is run in the test.
    //
    // At one point I tried using a special test-checking case of the enum, just
    // to carry the expected test "error message", but this required ignoring
    // which enum case carried the real error message, and that seemed bad.

    public static func ==(lhs: OptionError,
                          rhs: OptionError) -> Bool {
   
        // func longerContainsShorter(_ one: String, _ two: String) -> Bool {
        //     // s.contains("") is false for any String s, it seems; but if either
        //     // parameter is empty, surely the empty one is contained by the
        //     // other.
        //     if one == "" || two == "" {
        //         return true
        //     }
        //     let oneLonger = one.count > two.count
        //     return (oneLonger && one.contains(two))
        //         || (!oneLonger && (two.contains(one)))
        // }

        func oneContainsOther(_ dum: String, _ dee: String) -> Bool {
            // It's possible to write a version of this function that checks the
            // lengths of the two strings and avoids one of the two contains()
            // calls; but the gain is an improvement of efficiency that occurs
            // only during unit testing and is very likely minimal, while the
            // cost is a noticeably more complicated mental effort in checking
            // the code, so it's a net loss. (But see the commented-out function
            // above to realize that it seduced me for a while.)
            //
            // The last two checks, for the case where one string is empty, are
            // unavoidable because s.contains("") is false for any String s. I
            // suppose there must be a good argument for this, but not here:
            // if the parameters are error messages, and either one is empty,
            // we want to think the empty one is contained by the other.
            
            return dum.contains(dee) || dee.contains(dum)
                || dum == "" || dee == ""
        }
        
        switch (lhs, rhs) {
        case (.failedParse(let left), .failedParse(let right)):
            return oneContainsOther(left, right)
        case (.failedGet(let left), .failedGet(let right)):
            return oneContainsOther(left, right)
        default:
            return false
        }
    }
}


extension OptionScanner.Option : CustomStringConvertible {
    
    public var description: String {
        func yesno(_ choice: Bool) -> String { return choice ? "Y" : "N" }

        var result = ""

        result += "Option \'\(optionChar)\'"
        result += " req? " + yesno(isRequired)
        result += " set? " + yesno(isSet)
        result += " plus OK? " + yesno(allowsPlus)
        result += " set with plus? " + yesno(isSetWithAlt)
        result += "  takes arg? " + yesno(takesArg)
        if takesArg {
            let desc = argDescription ?? "[none]"
            result += " arg desc:\(desc)"
            if isSet {
                result += " value:\(arg!)"
            }
        }
        result += "  takes plus arg? " + yesno(takesPlusArg)
        if takesPlusArg {
            let desc = argForAltDescription ?? "[none]"
            result += " arg desc:\(desc)"
            if isSetWithAlt {
                result += " value:\(argForAlt!)"
            }
        }
        
        result += "\n"

        return result
    }
}


class SubUser: OptionUser {
    let optionString: String
    let programName: String
    let scanner: OptionScanner
    
    var options = [OptionScanner.Option]()
    
    var usageString = ""
    var usageMessage = "Meaningless default usage message"
    
    var output = ""
    
    func notifyUsageStringReady() {
        usageMessage = "Usage: \(programName) \(usageString)"
    }
    
    func notifyOptionsReady() {
        // This mess reflects the history of various choices that were useful
        // in different ways. Sorry about that!
        
        output += "\(programName): set options:"
        for o in options where o.isSet {
            output += " \(o.optionChar)"
        }
        output += "\n"
        output += "\(programName): setWithAlt options:"
        for o in options where o.isSetWithAlt {
            output += " \(o.optionChar)"
        }
        output += "\n"
        output += "\(programName): unset options:"
        for o in options where !o.isSet && !o.isSetWithAlt{
            output += " \(o.optionChar)"
        }
        output += "\n"
        
        // Let's try a couple of patterns for using scanner results in a
        // real program.
        
        self.output += "using dictionary of closures...\n"
        let actions = [
            "c": { self.output += "tardy c\n" },
            "d": { self.output += "d\n" },
            "e": { self.output += "tardy e\n" },
            "f": { self.output += "f\n" },
            "g": { self.output += "g\n" },
            "h": { self.output += "h\n" },
        ]
        
        for o in options where o.isSet || o.isSetWithAlt {
            actions[String(o.optionChar)]!()
        }
        
        self.output += "using switch statement...\n"
        
        for o in options where o.isSet || o.isSetWithAlt {
            switch o.optionChar {
            case "c": self.output += "tardy c\n"
            case "d": self.output += "d\n"
            case "e": self.output += "tardy e\n"
            case "f": self.output += "f\n"
            case "g": self.output += "g\n"
            case "h": self.output += "h\n"
            default: self.output += usageMessage
            }
        }
    }
    
    // Inappropriately call the scanner's usageString(). (The main program
    // should do this.) The point is just to check that it can be done and works
    // as expected.
    //
    // Returns: the main program's usage string returned by
    //  scanner.usageString().
    func dontDoThisCallUsageString() -> String {
        return scanner.usageString()
    }
    
    // Inappropriately call the scanner's getOpts(). (The main program
    // should do this.) The point is just to check that it can be done and works
    // as expected.
    //
    // Parameter:
    //  args: the list of arguments to be scanned
    //
    // Returns: the args-read count returned by scanner.getOpts().
    func dontDoThisCallGetOpts(_ args: [String]) throws -> Int {
        return try scanner.getOpts(args)
    }
    
    func addSelfToScanner() throws {
        try scanner.addUser(self, optionString)
    }
    
    init(_ optionString: String,
         progName programName: String,
         scanner: OptionScanner)
    {
        self.optionString = optionString
        self.programName = programName
        self.scanner = scanner
    }
}


final class OptionScannerTests: XCTestCase {

//    static var allTests = [
//        ("testExample", testExample),
//    ]
    
    // TESTS WITH NO SUBUSERS
    
    // Tests involving successful parsing.
    
    func testParseSimple() {
        let scanner = try! OptionScanner("ab:<example>!c")
        XCTAssert(scanner.options.keys.count == 3)
        var keylist = ""
        var descriptions = ""
        for key in scanner.options.keys.sorted() {
            var option: OptionScanner.Option
            option = scanner.options[key]!
            keylist += String(option.optionChar)
            descriptions += option.description
        }
        XCTAssert(keylist == "abc")
        XCTAssert(descriptions == """
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:example  takes plus arg? N
Option 'c' req? Y set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

""", "actual output: \(descriptions)"
        )
    }
    
    struct ParseCase {
        var optString: String
        var keys: String
        var description: String
        
        init(_ optString: String, _ keys: String, _ description: String) {
            self.optString = optString
            self.keys = keys
            self.description = description
        }
    }

    let parseCases = [
        ParseCase("", "",""),
        // interesting cases not at end of option string
        ParseCase("ab:<example>!c", "abc","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:example  takes plus arg? N
Option 'c' req? Y set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        ParseCase("ab:<two words>!c", "abc","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:two words  takes plus arg? N
Option 'c' req? Y set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        ParseCase("!b:c", "bc","""
Option 'b' req? Y set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N
Option 'c' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        ParseCase("c+!b:<minus><plus>!a", "abc","""
Option 'a' req? Y set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? Y set? N plus OK? Y set with plus? N  takes arg? Y arg desc:minus  takes plus arg? Y arg desc:plus
Option 'c' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        ParseCase("+!b:<minus>a", "ab","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? Y set? N plus OK? Y set with plus? N  takes arg? Y arg desc:minus  takes plus arg? Y arg desc:[none]

"""),
        ParseCase("+b:a", "ab","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? Y set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? Y arg desc:[none]

"""),
        // interesting cases at end of option string
        ParseCase("ab:<example>", "ab","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:example  takes plus arg? N

"""),
        ParseCase("!b:", "b","""
Option 'b' req? Y set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N

"""),
        ParseCase("+!b:<minus><plus>", "b","""
Option 'b' req? Y set? N plus OK? Y set with plus? N  takes arg? Y arg desc:minus  takes plus arg? Y arg desc:plus

"""),
        ParseCase("+!b:<minus>", "b","""
Option 'b' req? Y set? N plus OK? Y set with plus? N  takes arg? Y arg desc:minus  takes plus arg? Y arg desc:[none]

"""),
        ParseCase("+!b:", "b","""
Option 'b' req? Y set? N plus OK? Y set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? Y arg desc:[none]

"""),
        ParseCase("a:b:", "ab","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N

"""),
        ParseCase("a:cb:d", "abcd","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N
Option 'c' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'd' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        ParseCase("a:!b:", "ab","""
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N
Option 'b' req? Y set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N

"""),
        // Next case: two of all options, prompted by failure in Java Case 10
        // ("a:b:") caused by loop-control bug in buildUsageString().
        ParseCase("+!a:+d:!b:h:+!c+f!eg", "abcdefgh","""
Option 'a' req? Y set? N plus OK? Y set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? Y arg desc:[none]
Option 'b' req? Y set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N
Option 'c' req? Y set? N plus OK? Y set with plus? N  takes arg? N  takes plus arg? N
Option 'd' req? N set? N plus OK? Y set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? Y arg desc:[none]
Option 'e' req? Y set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'f' req? N set? N plus OK? Y set with plus? N  takes arg? N  takes plus arg? N
Option 'g' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'h' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:[none]  takes plus arg? N

"""),
    ]
    
    func testParseMulti() {
        for i in 0 ..< parseCases.count {
            let idMsg = "case: \(i): \(parseCases[i])"
            let scanner = try! OptionScanner(parseCases[i].optString)
            XCTAssertEqual(String(scanner.options.keys.sorted()), parseCases[i].keys, idMsg)
            var keylist = ""
            var description = ""
            for key in scanner.options.keys.sorted() {
                var option: OptionScanner.Option
                option = scanner.options[key]!
                keylist += String(option.optionChar)
                description += option.description
            }
            XCTAssertEqual(keylist, parseCases[i].keys, idMsg) // fussy
            XCTAssertEqual(description, parseCases[i].description)
        }
    }
    
    // Actually, only the plus character matters in parsing, but we'll change
    // the minus character too.
    func testParseWeirdMinusPlus() {
        let scanner = try! OptionScanner("6ba",
            optionIndicator:"5", alternativeOptionIndicator: "6")
        XCTAssertEqual(String(scanner.options.keys.sorted()), "ab")
        var option = scanner.options["a"]!
        XCTAssertEqual(option.description, """
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

""")
        option = scanner.options["b"]!
        XCTAssertEqual(option.description, """
Option 'b' req? N set? N plus OK? Y set with plus? N  takes arg? N  takes plus arg? N

""")
    }
    
    // Tests involving parsing errors

    struct ParseFailCase {
        var optString: String
        var msgPattern: String // must appear in error message
        
        init(_ optString: String, _ msgPattern: String) {
            self.optString = optString
            self.msgPattern = msgPattern
        }
    }

    let parseFailCases = [
        ParseFailCase("a+", "ended prematurely"),
        ParseFailCase("a!", "ended prematurely"),
        // Next case checks that !+ fails (The + must come before the !.)
        ParseFailCase("a!+b", "bad character '+'"),
        // Next case tries giving an option argument description where
        // none are needed.
        ParseFailCase("ab<argname>", "bad character '<'"),
        // Next case tries giving an extra option argument description where
        // only one is needed.
        ParseFailCase("ab:<one><two>", "bad character '<'"),
        ParseFailCase("a@b", "bad character '@'"),
        ParseFailCase("cbc", "duplicate option character 'c'"),
    ]
    
    func testParseMultiErrors() {
        
        for i in 0 ..< parseFailCases.count {
            let msgID = "case \(i): "
            let optString = parseFailCases[i].optString
            let msgPattern = parseFailCases[i].msgPattern
            let explanation = msgID + "expected error including: \""
                + msgPattern + "\""
            XCTAssertThrowsError(try OptionScanner(optString), explanation) {
                error in
                XCTAssertEqual(error as? OptionError,
                               .failedParse(msgPattern),
                               "wrong error message: \(error)")
            }
        }

    }


    // Tests involving usage strings
    
    struct UsageCase {
        // In the end the test cases involving subusers were put in a separate
        // section, farther down.
        var main: String
        var sub1: String?
        var sub2: String?
        var expected: [String] // 4 elements: all, main, sub1, sub2
        
        init(_ main: String, _ sub1: String?, _ sub2: String?, _ expected: [String]) {
            self.main = main
            self.sub1 = sub1
            self.sub2 = sub2
            self.expected = expected
        }
    }

    let simpleUsageCases = [
        // No submodules; want to see expected[1] == expected[0]
        UsageCase("", nil, nil, ["", "", "", ""]),
        UsageCase("abcB?", nil, nil, ["[ -?abBc ]", "", "", ""]),
        UsageCase("+ab!cB", nil, nil, ["-c [ -bB ] [ +/-a ]", "", "", ""]),
        UsageCase("ab!cB", nil, nil, ["-c [ -abB ]", "", "", ""]),
        UsageCase("+!ab+!A", nil, nil, ["[ -b ] +/-aA", "", "", ""]),
        UsageCase("+ab+A", nil, nil, ["[ -b ] [ +/-aA ]", "", "", ""]),
        UsageCase("ab:", nil, nil, ["[ -a ] [ -b optionitem1 ]", "", "", ""]),
        UsageCase("a+b:", nil, nil, ["[ -a ] [ -b optionitem1 | +b optionitem2 ]", "", "", ""]),
        UsageCase("+b:<descA>", nil, nil, ["[ -b descA | +b optionitem1 ]", "", "", ""]),
        UsageCase("+b:<descA><descB>", nil, nil, ["[ -b descA | +b descB ]", "", "", ""]),
        UsageCase("+b:<descA><descB>", nil, nil, ["[ -b descA | +b descB ]", "", "", ""]),
        UsageCase("a:b:", nil, nil, ["[ -a optionitem1 ] [ -b optionitem2 ]", "", "", ""]),
        UsageCase("a:cb:d", nil, nil, ["[ -cd ] [ -a optionitem1 ] [ -b optionitem2 ]", "", "", ""]),
        UsageCase("a:!b:", nil, nil, ["-b optionitem1 [ -a optionitem2 ]", "", "", ""]),
    ]

    func testUsageSimpleMulti() {
        for i in 0 ..< simpleUsageCases.count {
            let idMsg = "case: \(i): \(simpleUsageCases[i])"
            let scanner = try! OptionScanner(simpleUsageCases[i].main)
            let allUsage = scanner.usageString(returnSpecificCreatorOptions: false)
            XCTAssertEqual(allUsage, simpleUsageCases[i].expected[0], idMsg)
            let mainUsage = scanner.usageString()
            XCTAssertEqual(mainUsage, simpleUsageCases[i].expected[0], idMsg)
//            let sub1Usage = scanner.usageString(useAllOptions: false, user: sub1)
//            XCTAssertEqual(sub1Usage, usageCases[i].expected[2], idMsg)
        }
    }


// Ruins of preparatory work:
        //     switch error {
        //     case OptionError.failedParse(let msg):
        //         XCTAssert(msg.contains(msgPattern),
        //                   "wrong error message: \(msg)")
        //         break
        //     default:
        //         XCTFail("wrong error type; message: \(error)")
        //     }
        // }
//
//                XCTAssertThrowsError(try OptionScanner("a+"),
//                "expected \"ended prematurely\" error") {
//            error in
// //            XCTAssertEqual(error as? OptionError,
// //                           .failedParse(""), "wrong error type")
//            // let opterror = error as? OptionError.failedParse
//            // XCTAssert(opterror.msg.contains("premature"))
//            switch error {
//            case OptionError.failedParse(let msg):
//                XCTAssert(msg.contains("ended prematurely"),
//                    "wrong error message: \(msg)")
//                break
//            default:
// //                XCTAssert(false, "wrong error type")
//                XCTFail("wrong error type")
//            }
//        }


    // Tests involving successful getting.

    struct GetCase {
        var optString: String
        var args: [String]
        var returnedIndex: Int
        var description: String
        
        init(_ optString: String, _ args: [String], _ returnedIndex: Int, _ description: String) {
            self.optString = optString
            self.args = args
            self.returnedIndex = returnedIndex
            self.description = description
        }
    }

    let getCases = [
        GetCase("", ["prog", "notanoption", "notthefirstnonoption"], 1, ""),
        GetCase("ab:<example>c", ["prog", "-a", "notanoption"], 2, """
Option 'a' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:example  takes plus arg? N
Option 'c' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        GetCase("ab:<example>!c", ["prog", "-bvalue1", "-c", "--", "-a"], 4, """
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? Y plus OK? N set with plus? N  takes arg? Y arg desc:example value:value1  takes plus arg? N
Option 'c' req? Y set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        GetCase("ab:<example>c", ["prog", "-b", "value2", "-c"], 4, """
Option 'a' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? Y plus OK? N set with plus? N  takes arg? Y arg desc:example value:value2  takes plus arg? N
Option 'c' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        GetCase("ab:<example>c", ["prog", "-a", "-"], 2, """
Option 'a' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:example  takes plus arg? N
Option 'c' req? N set? N plus OK? N set with plus? N  takes arg? N  takes plus arg? N

"""),
        GetCase("b:<example>+d+ca", ["prog", "-d", "-a", "+c", "+d", "notopt"], 5, """
Option 'a' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y arg desc:example  takes plus arg? N
Option 'c' req? N set? N plus OK? Y set with plus? Y  takes arg? N  takes plus arg? N
Option 'd' req? N set? Y plus OK? Y set with plus? Y  takes arg? N  takes plus arg? N

"""),
        GetCase("+!b:<minus><plus>", ["prog", "+b", "plusval", "-bminusval", "notopt"], 4, """
Option 'b' req? Y set? Y plus OK? Y set with plus? Y  takes arg? Y \
arg desc:minus value:minusval  takes plus arg? Y arg desc:plus value:plusval

"""),
        GetCase("+!b:<minus><plus>", ["prog", "+b", "plusval", "notopt"], 3, """
Option 'b' req? Y set? N plus OK? Y set with plus? Y  takes arg? Y \
arg desc:minus  takes plus arg? Y arg desc:plus value:plusval

"""),
        GetCase("+!b:<minus><plus>", ["prog", "-b", "minusval", "notopt"], 3, """
Option 'b' req? Y set? Y plus OK? Y set with plus? N  takes arg? Y \
arg desc:minus value:minusval  takes plus arg? Y arg desc:plus

"""),
        GetCase("a:b:", ["prog", "-a", "-b"], 3, """
Option 'a' req? N set? Y plus OK? N set with plus? N  takes arg? Y \
arg desc:[none] value:-b  takes plus arg? N
Option 'b' req? N set? N plus OK? N set with plus? N  takes arg? Y \
arg desc:[none]  takes plus arg? N

"""),
    ]

    func testGetMulti() {
        for i in 0 ..< getCases.count {
            let idMsg = "case: \(i): \(getCases[i])"
            let scanner = try! OptionScanner(getCases[i].optString)
            let returnedIndex = try! scanner.getOpts(getCases[i].args)
            XCTAssertEqual(returnedIndex, getCases[i].returnedIndex, idMsg)
            // XCTAssertNoThrow(try scanner.getOpts(getCases[i].args), idMsg)
            var description = ""
            for key in scanner.options.keys.sorted() {
                var option: OptionScanner.Option
                option = scanner.options[key]!
                description += option.description
            }
            XCTAssertEqual(description, getCases[i].description, idMsg)
        }
    }

    func testGetWeirdMinusPlus() {
        let scanner = try! OptionScanner("6ba",
            optionIndicator:"5", alternativeOptionIndicator: "6")
        XCTAssertEqual(String(scanner.options.keys.sorted()), "ab")
        let returnedIndex = try! scanner.getOpts(["oddprog", "5b", "5a", "6b"])
        XCTAssertEqual(returnedIndex, 4, "odd-case get wrong return")
        var option = scanner.options["a"]!
        XCTAssertEqual(option.description, """
Option 'a' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N

""")
        option = scanner.options["b"]!
        XCTAssertEqual(option.description, """
Option 'b' req? N set? Y plus OK? Y set with plus? Y  takes arg? N  takes plus arg? N

""")
    }

    func testGetReallyWeirdMinusPlus() {
        // Don't try this at home.
        let scanner = try! OptionScanner("abbxby",
            optionIndicator:"a", alternativeOptionIndicator: "b")
        XCTAssertEqual(String(scanner.options.keys.sorted()), "abxy")
        let returnedIndex =
            try! scanner.getOpts(["oddprog", "ax", "aa", "bb", "by", "ay"])
        XCTAssertEqual(returnedIndex, 6, "very-odd-case get wrong return")
        var option = scanner.options["a"]!
        XCTAssertEqual(option.description, """
Option 'a' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N

""")
        option = scanner.options["b"]!
        XCTAssertEqual(option.description, """
Option 'b' req? N set? N plus OK? Y set with plus? Y  takes arg? N  takes plus arg? N

""")
        option = scanner.options["x"]!
        XCTAssertEqual(option.description, """
Option 'x' req? N set? Y plus OK? N set with plus? N  takes arg? N  takes plus arg? N

""")
        option = scanner.options["y"]!
        XCTAssertEqual(option.description, """
Option 'y' req? N set? Y plus OK? Y set with plus? Y  takes arg? N  takes plus arg? N

""")
    }

    
    // Tests involving getting errors

    struct GetFailCase {
        var optString: String
        var args: [String]
        var msgPattern: String // must appear in error message
        
        init(_ optString: String, _ args: [String],  _ msgPattern: String) {
            self.optString = optString
            self.args = args
            self.msgPattern = msgPattern
        }
    }

    let getFailCases = [
        GetFailCase("", ["prog", "-a"], "option 'a' not recognized"),
        GetFailCase("a", ["prog", "-b"], "option 'b' not recognized"),
        GetFailCase("a", ["prog", "+a"], "'+' used with option 'a'"),
        GetFailCase("ab", ["prog", "-b", "-a", "-barg"], "option 'b' set twice"),
        GetFailCase("a+b", ["prog", "-b", "-a", "+b", "+b"], "option 'b' set twice"),
        GetFailCase("a+b", ["prog", "+b", "-a", "+b"], "option 'b' set twice"),
        GetFailCase("ab:", ["prog", "-abarg"], "option 'b' not first in argument"),
        GetFailCase("ab:", ["prog", "-a", "-b"], "missing argument for option 'b'"),
        GetFailCase("a!b", ["prog", "-a"], "required option 'b' not set"),
    ]
    
    func testGetMultiErrors() {
        for i in 0 ..< getFailCases.count {
            let msgID = "case \(i): "
            let args = getFailCases[i].args
            let msgPattern = getFailCases[i].msgPattern
            let explanation = msgID + "expected error including: \""
                + msgPattern + "\""
            // The get tests can only occur after a successful parse.
            let scanner = try! OptionScanner(getFailCases[i].optString)
            XCTAssertThrowsError(try scanner.getOpts(args), explanation) {
                error in
                XCTAssertEqual(error as? OptionError,
                               .failedGet(msgPattern),
                               "wrong error message: \(error)")
            }

        }
    }

    
    // TESTS WITH SUBUSERS
    
    func testSimpleAddUser() {
        
        let msgID = "case \"simple addUser\": "
        let scanner = try! OptionScanner("abc")
        let subuser1 = SubUser("de", progName: "progA", scanner: scanner)
        try! subuser1.addSelfToScanner()
        let usageString = scanner.usageString()
        XCTAssertEqual(usageString, "[ -abc ]")
        XCTAssertEqual(subuser1.usageString, "[ -de ]")
        
        let nextArg = try! scanner.getOpts(["prog", "-abd"])
        XCTAssertEqual(nextArg, 2)
        XCTAssert(scanner.options["a"]!.isSet, msgID)
        XCTAssert(scanner.options["b"]!.isSet, msgID)
        XCTAssert(!scanner.options["c"]!.isSet, msgID)
        
        XCTAssert(scanner.options["d"]!.isSet, msgID)
        XCTAssert(!scanner.options["e"]!.isSet, msgID)
        XCTAssert(subuser1.options[0].isSet, msgID)
        XCTAssert(!subuser1.options[1].isSet, msgID)
        
        XCTAssertEqual(subuser1.output, """
progA: set options: d
progA: setWithAlt options:
progA: unset options: e
using dictionary of closures...
d
using switch statement...
d

""")
    }
    
    func testAddUserWithDoubleUsageString() {
        
        let msgID = "case \"addUser with double usageString()\": "
        let scanner = try! OptionScanner("abg")
        let subuser1 = SubUser("de", progName: "progA", scanner: scanner)
        try! subuser1.addSelfToScanner()
        let subuser2 = SubUser("hf", progName: "progB", scanner: scanner)
        try! subuser2.addSelfToScanner()

        // one
        let usageStringOne = scanner.usageString()
        XCTAssertEqual(usageStringOne, "[ -abg ]")
        XCTAssertEqual(subuser1.usageString, "[ -de ]")
        XCTAssertEqual(subuser2.usageString, "[ -fh ]")

        // two
        let usageStringTwo = scanner.usageString(
                returnSpecificCreatorOptions:false
            )
        XCTAssertEqual(usageStringTwo, "[ -abdefgh ]")
        XCTAssertEqual(subuser1.usageString, "[ -de ]")
        XCTAssertEqual(subuser2.usageString, "[ -fh ]")
        
        // If we got here, usage strings are OK. Now we check that scanning is
        // all right too, though there's no reason to suspect a second call to
        // usageString() would affect getOpts().
        let nextArg = try! scanner.getOpts(["prog", "-ad", "-h"])
        XCTAssertEqual(nextArg, 3)
        XCTAssert(scanner.options["a"]!.isSet, msgID)
        XCTAssert(!scanner.options["b"]!.isSet, msgID)
        XCTAssert(!scanner.options["g"]!.isSet, msgID)

        XCTAssert(scanner.options["d"]!.isSet, msgID)
        XCTAssert(!scanner.options["e"]!.isSet, msgID)
        XCTAssert(!scanner.options["f"]!.isSet, msgID)
        XCTAssert(scanner.options["h"]!.isSet, msgID)
        
        XCTAssert(subuser1.options[0].isSet, msgID)
        XCTAssert(!subuser1.options[1].isSet, msgID)
        
        XCTAssertEqual(subuser1.output, """
progA: set options: d
progA: setWithAlt options:
progA: unset options: e
using dictionary of closures...
d
using switch statement...
d

""")
        
        XCTAssert(!subuser2.options[0].isSet, msgID)
        XCTAssert(subuser2.options[1].isSet, msgID)
        
        XCTAssertEqual(subuser2.output, """
progB: set options: h
progB: setWithAlt options:
progB: unset options: f
using dictionary of closures...
h
using switch statement...
h

""")
    }
    
    func testEmptyAddUser() {
        
        let msgID = "case \"empty addUser\": "
        let scanner = try! OptionScanner("")
        let subuser1 = SubUser("", progName: "progA", scanner: scanner)
        try! subuser1.addSelfToScanner()
        let usageString = scanner.usageString()
        XCTAssertEqual(usageString, "")
        XCTAssertEqual(subuser1.usageString, "")
        
        let nextArg = try! scanner.getOpts(["prog", "hi"])
        XCTAssertEqual(nextArg, 1)
        XCTAssert(scanner.options.isEmpty, msgID)
        XCTAssert(subuser1.options.isEmpty, msgID)
        
        XCTAssertEqual(subuser1.output, """
progA: set options:
progA: setWithAlt options:
progA: unset options:
using dictionary of closures...
using switch statement...

""")
    }

    func testParseLateAddUser() {
        let msgID = "case \"late addUser\": "
        let explanation = msgID + "expected add-user-too-late error"
        let scanner = try! OptionScanner("abf")
        let subuser1 = SubUser("dg", progName: "progA", scanner: scanner)
        try! subuser1.addSelfToScanner()
        // Next line: subuser1 can't re-add itself with a different
        // optionString (because the optionString is built-in to it), so we'll
        // do the naughty work for it.
        XCTAssertNoThrow(try scanner.addUser(subuser1, "ec"), msgID)
            // whee! twice!
        XCTAssertEqual(scanner.options.keys.sorted(),
                       ["a", "b", "c", "d", "e", "f", "g"], msgID)
        XCTAssertEqual(scanner.usageString(returnSpecificCreatorOptions: false),
                       "[ -abcdefg ]", msgID)
        // After calling usageString(), can't addUser().
        let subuser2 = SubUser("mn", progName: "progB", scanner: scanner)
        // XCTAssertThrowsError(try scanner.addUser(subuser2, "mn"), explanation) {
        XCTAssertThrowsError(try subuser2.addSelfToScanner(), explanation) {
            error in
            XCTAssertEqual(error as? OptionError,
                           .failedParse("too-late attempt to add"),
                           explanation)
        }
    }
    
    func testSubuserCallsUsageString() {
        let msgID = "case \"subuser calls usageString\": "
        let scanner = try! OptionScanner("abf")
        let subuser1 = SubUser("dg", progName: "progA", scanner: scanner)
        try! subuser1.addSelfToScanner()
        
        XCTAssertEqual(subuser1.usageString, "", msgID)
        XCTAssertEqual(subuser1.dontDoThisCallUsageString(), "[ -abf ]", msgID)
        XCTAssertEqual(subuser1.usageString, "[ -dg ]", msgID)
    }
    
    func testSubuserCallsGetOpts() {
        let msgID = "case \"subuser calls getOpts\": "
        let scanner = try! OptionScanner("abf")
        let subuser1 = SubUser("dg", progName: "progA", scanner: scanner)
        try! subuser1.addSelfToScanner()
        
        // Make a String out of listed option characters that are set.
        func setOptionsToStr(_ list: [OptionScanner.Option]) -> String {
            var result = ""
            for o in list where o.isSet {
                result.append(o.optionChar)
            }
            return result
        }
        
        // pre-checks
        XCTAssertEqual(scanner.allOptions.count, 0, msgID)
        XCTAssertEqual(setOptionsToStr(scanner.creatorOptions).count, 0, msgID)

        // Make the call.
        let args = ["prog", "-g", "-a", "-b", "ordinaryarg"]
        XCTAssertEqual(try subuser1.dontDoThisCallGetOpts(args), 4, msgID)
        
        // post-checks: all options, and main's and subuser's set options
        XCTAssertEqual(scanner.allOptions.count, 5, msgID)
        XCTAssertEqual(setOptionsToStr(scanner.creatorOptions), "ab", msgID)
        XCTAssertEqual(setOptionsToStr(subuser1.options), "g", msgID)
    }

}
