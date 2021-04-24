//
//  TestsFromJava.swift
//  DevOptPkgTests
//
//  Created by Jim Clarke on 2021-04-12.
//

import XCTest
//@testable import StringUtilitiesTests
// Reproducing the tests from the Java version of 2003.

// The compiler won't let us override OptionError.== (which is fine) or the
// yesno and description in OptionScanner.Option (which means we have to
// provide separate versions for use here, typically with names beginning
// "java...").

extension OptionScanner.Option {
    
    public var javaDescription: String {
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

class JavaSubUser: OptionUser {
    
    // For the tests in TestOptionScanner.java.
        
    let optionString: String
    let toString: String // so we can pretend to be Java
    
    let scanner: OptionScanner

    var optionList = ""
    
    var options = [OptionScanner.Option]()
    
    var usageString = ""
    var usageMessage = "Meaningless default usage message"
    
    var output = ""
    
    func notifyUsageStringReady() {
        usageMessage = "Usage: \(optionString) \(usageString)"
    }
    
    // The strings needed by the "program" that owns this OptionUser
    var reportHeader = ""
    var reportTail = ""
    var optionCharacters = ""
    
    func notifyOptionsReady() {        
        // Build report header and tail.
        
        reportHeader += toString + " notified; report:" + "\n"
        reportHeader += "-----" + "\n"
        
        reportTail += "--- end of report from " + toString
        
        // Build optionCharacters from the list of options
        //
        // Why? An OptionUser doesn't intrinsically know what options it owns.
        // If it were in a real program, it would know because it would have
        // some actual purpose in life. Here, this string, consisting of the
        // option characters, has to be built from the list of options. (It
        // could be built by removing +, ! etc. from the optionString, but that
        // seems error-prone.)
        
        optionCharacters = ""
        for o in options {
            optionCharacters += String(o.optionChar)
        }

    }
    
    func addSelfToScanner() throws {
        try scanner.addUser(self, optionString)
    }
    
    init(_ optionString: String, _ scanner: OptionScanner) {
        self.optionString = optionString
        self.scanner = scanner
        
        self.toString = "OptionUser \"" + optionString + "\""
    }
}

class JavaSubUser2: OptionUser {
    
    // For the tests in TestOptionScanner2.java.

    // We don't actually need these required attributes.
    var options = [OptionScanner.Option]()
    var usageString = ""
    
    let optionString: String
    let scanner: OptionScanner
    
    var someOptionsAreSet = false
    
    func notifyUsageStringReady() {
        // Don't need this.
    }
    
    func notifyOptionsReady() {
        for o in options {
            if o.isSet || o.isSetWithAlt {
                someOptionsAreSet = true
            }
        }
    }
    
    func addSelfToScanner() throws {
        try scanner.addUser(self, optionString)
    }
    
    init(_ optionString: String, _ scanner: OptionScanner) {
        self.optionString = optionString
        self.scanner = scanner
    }
}


class OptionScannerTestsFromJava: XCTestCase {
    
    // First, the tests from TestOptionScanner.java, then the tests from
    // TestOptionScanner2.java.
    
    //---------------------------------//
    
    // But really "first", some functions we need.

    var outBuffer = ""
    
    func write(_ line: String) {
        outBuffer += line
    }
    
    func writeln(_ line: String) {
        write(line + "\n")
    }

    
    func putSimpleCase(_ simple: SimpleCase,
                clearBuf: Bool = true,
                optionIndicator minusChar: Character = "-",
                alternativeOptionIndicator plusChar: Character = "+")
    {
        // Hmph. Can't use "case" as parameter name.
        if clearBuf {
            outBuffer = ""
        }
        
        writeln("Case \(simple.caseNum)")
        writeln("option string: \"\(simple.optionString)\"")
        
        let scanner: OptionScanner
        do {
            try scanner = OptionScanner(simple.optionString,
                                        optionIndicator: minusChar,
                                        alternativeOptionIndicator: plusChar
            )
            putCase(scanner, simple.args, simple.charsToPrint, clearBuf: false)
        }
        catch OptionError.failedParse(let msg) {
            writeln("exception while creating scanner: \(msg)")
            // writeln("")
        }
        catch {
            writeln("unexpected error \(error)")
        }
    }
    
    func putCase(_ scanner: OptionScanner,
                 _ args: [String],
                 _ charsToPrint: String,
                 clearBuf: Bool = true
                )
    {
        if clearBuf {
            outBuffer = ""
        }
        
        // Fix the "options" ... er, "args" ... to be Swift-style.
        var fixedArgs = args
        fixedArgs.insert("prog", at: 0)
        
        writeln("entire usage string: \"\(scanner.usageString(returnSpecificCreatorOptions: false))\"")
        writeln("usage string for main: \"\(scanner.usageString())\"")
        
        putOptions(args: args)
            // not fixedArgs: the output has to look like Java
        
        do {
            var firstUnused: Int
            try firstUnused = scanner.getOpts(fixedArgs)
            writeln("arguments scanned: \(firstUnused - 1)")
            // -1 to match Java command line (which omits $0)
        }
        catch OptionError.failedGet(let msg) {
            writeln("exception while scanning: \(msg)")
        }
        catch {
            writeln("unexpected error \(error)")
        }
        
        putResults(chars: charsToPrint, scanner: scanner)
        // writeln("")
    }
    
    func putOptions(args: [String]) {
        write("command-line arguments:")
        for o in args {
            write(" \"\(o)\"")
        }
        writeln("")
    }
    
    func putResults(chars: String, scanner: OptionScanner) {
        let options = scanner.options
        for c in chars {
            writeln("'\(c)' ...")
            let optionalOption = options[c]
            if optionalOption == nil {
                writeln("exception: queried nil option")
                continue
            }
            let o = optionalOption!
            write(" ? set: ")
            writeln((o.isSet ? "yes" : "no"));

            write(" ? plus set: ")
            writeln(o.isSetWithAlt ? "yes" : "no")

            write(" ? arg: ")
            if let arg = o.arg {
                writeln("\"\(arg)\"")
            } else if !o.takesArg {
                writeln("exception: option argument queried on non-arg option '\(c)'")
            } else {
                writeln("exception: option argument queried on unset option '\(c)'")
            }
            
            write(" ? plus arg: ")
            if let argForAlt = o.argForAlt {
                writeln("\"\(argForAlt)\"")
            } else if !o.takesPlusArg {
                writeln("exception: plus option argument queried on non-plus-arg option '\(c)'")
            } else {
                writeln("exception: plus option argument queried on unset option '\(c)'")
            }
        }
    }

    // End of the needed functions
    
    //---------------------------------//


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    struct SimpleCase {
        let caseNum: Int
        let optionString: String
        let args: [String] // Java code calls this "options"
        let charsToPrint: String
        
        init(_ caseNum: Int,
             _ optionString: String,
             _ args: [String],
             _ charsToPrint: String)
        {
            self.caseNum = caseNum
            self.optionString = optionString
            self.args = args
            self.charsToPrint = charsToPrint
        }
    }
    
    let simpleCases = [
        SimpleCase(0, "", [], ""), // Case 0 -- not present in Java set
        SimpleCase(1, "ab:c", 
                   ["-a", "-b", "jim"],
                   "abc"),
        SimpleCase(2, 
                   "dc!b:<item name>+a",
                   ["-c", "-a", "-bjim", "+a", "--", "filename"],
                   "abcd"),
        SimpleCase(3, 
                    "zH2#1hbR?",
                    ["-?H", "-zb1#", "nonoption"],
                    "#?bhHRz12"),
        SimpleCase(4, 
                    "",
                    ["-a", "-"],
                    "a"),
    
        // Case 5.
        SimpleCase(5,
                "+k+K+3+4+?+#",
                ["-k", "+K", "+34", "+"],
                "#?kK34"
                ),

        // Case 6.
        SimpleCase(6,
                "!a",
                ["-a", "z"],
                "a"
                ),

        // Case 7.
        SimpleCase(7,
                "!az!wd",
                ["-awd", ""],
                "adwz"
                ),

        // Case 8.
        SimpleCase(8,
                "+!h+!g+!w",
                ["-h", "+g", "+w", "-w"],
                "ghw"
                ),

        // Case 9.
        SimpleCase(9,
                "+!g+h",
                ["+h", "+g", "-"],
                "gh"
                ),

        // Case 10.
        SimpleCase(10,
                "a:b:",
                ["-a", "-b"],
                "ab"
                ),

        // Case 11.
        SimpleCase(11,
                "!a:!b:",
                ["-ahi", "-b", "there"],
                "ab"
                ),

        // Case 12.
        SimpleCase(12,
                "a:!b:",
                ["-b", "there"],
                "ab"
                ),

        // Case 13.
        SimpleCase(13,
                "+a:+b:<first>+c:<second><third>+d:",
                ["-aone", "+c", "two", "+b", "three", "-c", "four"],
                "abcd"
                ),

        // Case 14.
        SimpleCase(14,
                "+!a:+!b:<first>+!c:<second><third>+!d:",
                ["-aone", "-c", "two", "+c", "four", "+b", "three",
                "-dwhatever"],
                "abcd"
                ),

        // Case 15.
        SimpleCase(15,
                "+9:+!#:",
                ["+#there"],
                "9#"
                ),

        // Case 16.
        SimpleCase(16,
                "ab:+?:+9",
                ["-a", "-a"],
                "a"
                ),

        // Case 17.
        SimpleCase(17,
                "!a!b:+!?:+!9",
                ["-bhi", "+?there", "-9"],
                "a"
                ),

        // Case 18.
        SimpleCase(18,
                "!ab:+!?:+9",
                ["-a", "-9", "+?there", "-9"],
                ""
                ),

        // Case 19.
        SimpleCase(19,
                "+a+b:<one><two>+8z:",
                ["+a", "+a"],
                ""
                ),

        // Case 20.
        SimpleCase(20,
                "a+b:<one><two>8z:",
                ["-z", "hi", "-z", "again"],
                ""
                ),

        // Case 21.
        SimpleCase(21,
                "+h:<a><b>9+Y",
                ["-h", "hi", "-h", "again"],
                ""
                ),

        // Case 22.
        SimpleCase(22,
                "+h:<a><b>",
                ["+h", "hi", "+h", "again"],
                ""
                ),

        // Case 23.
        SimpleCase(23,
                "+!p",
                [],
                ""
                ),

        // Case 24.
        SimpleCase(24,
                "!q:",
                [],
                ""
                ),

        // Case 25.
        SimpleCase(25,
                "+!r:",
                [],
                ""
                ),

        // Case 26.
        SimpleCase(26,
                "s",
                ["+s"],
                "s"
                ),

        // Case 27.
        SimpleCase(27,
                "t:",
                ["+t", "hi"],
                "t"
                ),

        // Case 28.
        SimpleCase(28,
                "u:a",
                ["-au", "hi"],
                ""
                ),

        // Case 29.
        SimpleCase(29,
                "+v:b",
                ["-bvhi"],
                ""
                ),

        // Case 30.
        SimpleCase(30,
                "+w:+c",
                ["+cwhi"],
                ""
                ),

        // Case 31.
        SimpleCase(31,
                "x:",
                ["-x"],
                "x"
                ),

        // Case 32.
        SimpleCase(32,
                "+y:",
                ["-y"],
                "y"
                ),

        // Case 33.
        SimpleCase(33,
                "+z:",
                ["+z"],
                "z"
                ),

        // Case 34.
        SimpleCase(34,
                "+5:",
                ["-5hi", "+5"],
                "5"
                ),

        // Case 35.
        SimpleCase(35,
                "aba",
                [],
                ""
                ),

        // Case 36.
        SimpleCase(36,
                "ab+a",
                [],
                ""
                ),

        // Case 37.
        SimpleCase(37,
                "+aba:",
                [],
                ""
                ),

        // Case 38.
        SimpleCase(38,
                "ab+a:",
                [],
                ""
                ),

        // Case 39.
        SimpleCase(39,
                "ab<desc>",
                [],
                ""
                ),

        // Case 40.
        SimpleCase(40,
                "a+b<desc>",
                [],
                ""
                ),

        // Case 41.
        SimpleCase(41,
                "ab:<desc><another>",
                [],
                ""
                ),

        // Case 42.
        SimpleCase(42,
                "a+b:<desc><another><three>",
                [],
                ""
                ),

        // Case 43.
        SimpleCase(43,
                "ab*c",
                [],
                ""
                ),

        // Case 44.
        SimpleCase(44,
                "ab:<desc> c",
                [],
                ""
                ),

        // Case 45.
        SimpleCase(45,
                "a!+b",
                [],
                ""
                ),

        // Case 46.
        SimpleCase(46,
                "-ab",
                [],
                ""
                ),

        // Case 47.
        SimpleCase(47,
                "ab-",
                [],
                ""
                ),

        // Case 48.
        SimpleCase(48,
                "ab+",
                [],
                ""
                ),

        // Case 49.
        SimpleCase(49,
                "ab!",
                [],
                ""
                ),

        // Case 50.
        SimpleCase(50,
                "ab+!",
                [],
                ""
                ),

    
    ]
    


    func testJavaMultiSimpleCases() {
        for s in 1 ..< simpleCases.count {
            putSimpleCase(simpleCases[s])
            XCTAssertEqual(outBuffer, simpleExpecteds[s])
        }
    }
    
    // Different optionIndicator.
    func testJavaCase51() {
        let caseNum = 51
        let simple = SimpleCase(caseNum,
                                "a+bc:<one>+d:<two><three>",
                                ["/ab", "+b", "/cfirst", "/d", "second", "+dthird"],
                                "abcd"
        )
        putSimpleCase(simple, optionIndicator: "/")
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }
    
    // Case with subusers.
    func testJavaCase52() {
        let caseNum = 52
        let optionString = "cyz"
        outBuffer = ""
        writeln("Case \(caseNum)")
        writeln("option string: \"\(optionString)\"")

        // main user
        let scanner: OptionScanner
        try! scanner = OptionScanner(optionString)

        // subusers
        let user1 = JavaSubUser("abx", scanner)
        let user2 = JavaSubUser("+de:<2's arg>", scanner)
        try! user1.addSelfToScanner()
        try! user2.addSelfToScanner()

        // main user report
        putCase(scanner, ["-adc", "+d", "-zx", "-ehi"], "cyz", clearBuf: false)
        
        // subuser reports: usage strings ...
        writeln("usage string for \(user1.toString): \"\(user1.usageString)\"")
        writeln("usage string for \(user2.toString): \"\(user2.usageString)\"")
        
        // ... subuser option settings
        write(user1.reportHeader)
        putResults(chars: user1.optionCharacters, scanner: scanner)
        writeln(user1.reportTail)
        
        write(user2.reportHeader)
        putResults(chars: user2.optionCharacters, scanner: scanner)
        writeln(user2.reportTail)

        // And did it all work?
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }
    
    // Subuser when main user has empty optionString.
    func testJavaCase53() {
        let caseNum = 53
        let optionString = ""
        outBuffer = ""
        writeln("Case \(caseNum)")
        writeln("option string: \"\(optionString)\"")

        // main user
        let scanner: OptionScanner
        try! scanner = OptionScanner(optionString)

        // subusers
        let user1 = JavaSubUser("+f:<a><b>g", scanner)
        try! user1.addSelfToScanner()

        // main user report
        putCase(scanner, ["+f", "boo", "-g", "ehi"], "fg", clearBuf: false)
        
        // subuser reports: usage strings ...
        writeln("usage string for \(user1.toString): \"\(user1.usageString)\"")
        
        // ... subuser option settings
        write(user1.reportHeader)
        putResults(chars: user1.optionCharacters, scanner: scanner)
        writeln(user1.reportTail)

        // And did it all work?
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }
    
    // Subuser with empty optionString.
    func testJavaCase54() {
        let caseNum = 54
        let optionString = "j:<what>"
        outBuffer = ""
        writeln("Case \(caseNum)")
        writeln("option string: \"\(optionString)\"")

        // main user
        let scanner: OptionScanner
        try! scanner = OptionScanner(optionString)

        // subusers
        let user1 = JavaSubUser("", scanner)
        try! user1.addSelfToScanner()

        // main user report
        putCase(scanner, ["-jjim"], "j", clearBuf: false)
        
        // subuser reports: usage strings ...
        writeln("usage string for \(user1.toString): \"\(user1.usageString)\"")
        
        // ... subuser option settings
        write(user1.reportHeader)
        putResults(chars: user1.optionCharacters, scanner: scanner)
        writeln(user1.reportTail)

        // And did it all work?
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }
    
    // Subuser option character duplicates main user's option character.
    func testJavaCase55() {
        let caseNum = 55
        let optionString = "ab"
        outBuffer = ""
        writeln("Case \(caseNum)")
        writeln("option string: \"\(optionString)\"")

        // main user
        let scanner: OptionScanner
        try! scanner = OptionScanner(optionString)

        // subusers
        let user1 = JavaSubUser("ac", scanner)
        writeln("user: \(user1.toString)")
        
        // Got an error?
        XCTAssertThrowsError(try user1.addSelfToScanner(),
                             "repeated option character in subuser") {
            error in
            XCTAssertEqual(error as? OptionError,
                           .failedParse("duplicate option character 'a'"),
                           "subuser has duplicate option character")
        }
        
        // Output OK?
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }
    
    // Subuser option character duplicates other subuser's option character.
    func testJavaCase56() {
        let caseNum = 56
        let optionString = ""
        outBuffer = ""
        writeln("Case \(caseNum)")
        writeln("option string: \"\(optionString)\"")

        // main user
        let scanner: OptionScanner
        try! scanner = OptionScanner(optionString)

        // subusers
        let user1 = JavaSubUser("ac", scanner)
        writeln("first user: \(user1.toString)")
        let user2 = JavaSubUser("+cd", scanner)
        writeln("second user: \(user2.toString)")
        
        // Adding user1 should work ...
        try! user1.addSelfToScanner()

        // ... but adding user2 should fail on duplicate option character.
        XCTAssertThrowsError(try user2.addSelfToScanner(),
                             "repeated option character in subuser") {
            error in
            XCTAssertEqual(error as? OptionError,
                           .failedParse("duplicate option character 'c'"),
                           "subuser has duplicate option character")
        }
        
        // Output OK?
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }
    
    // Repeated re-use of scanner (without subusers).
    func testJavaCase57() {
        let caseNum = 57
        let optionString = "ab"
        outBuffer = ""
        writeln("Case \(caseNum)")
        writeln("option string: \"\(optionString)\"")

        // Create scanner.
        let scanner: OptionScanner
        try! scanner = OptionScanner(optionString)
        
        // Use the scanner (i.e., call scanner.getOpts()) for the first time.
        putCase(scanner, ["-a"], "ab", clearBuf: false)
        writeln("")
        
        // Now, three more getOpts() calls.
        var args: [String]
        var fixedArgs: [String]
        var firstUnused: Int
        
        // First extra call: OK because new args don't overlap previous one
        args = ["-b"] // prepending "prog" to Swiftify the arg list
        putOptions(args: args)
        fixedArgs = args
        fixedArgs.insert("prog", at: 0)
        firstUnused = try! scanner.getOpts(fixedArgs)
        writeln("arguments scanned: \(firstUnused - 1)")
        putResults(chars: "ab", scanner: scanner)
        writeln("")
        
        // Second extra call: not OK because new args do overlap previous ones
        args = ["-a"] // prepending "prog" to Swiftify the arg list
        putOptions(args: args)
        fixedArgs = args
        fixedArgs.insert("prog", at: 0)
        XCTAssertThrowsError(firstUnused = try scanner.getOpts(fixedArgs),
                             "getOpts call with previously set option") {
            error in
            XCTAssertEqual(error as? OptionError,
                           .failedGet("option 'a' set twice"),
                           "getOpts call with previously set option")
        }
        putResults(chars: "ab", scanner: scanner)
        writeln("")
        
        // Third extra call: not OK because new args do overlap previous ones
        args = ["-b"] // prepending "prog" to Swiftify the arg list
        putOptions(args: args)
        fixedArgs = args
        fixedArgs.insert("prog", at: 0)
        XCTAssertThrowsError(firstUnused = try scanner.getOpts(fixedArgs),
                             "getOpts call with previously set option") {
            error in
            XCTAssertEqual(error as? OptionError,
                           .failedGet("option 'b' set twice"),
                           "getOpts call with previously set option")
        }
        putResults(chars: "ab", scanner: scanner)
        
        // Output OK?
        XCTAssertEqual(outBuffer, simpleExpecteds[caseNum])
    }

    // The three cases in TestOptionScanner2.java
    func testJava2AllCases() {
        // There is no output from this test function.
        
        let optionString = "cyz" // same for all three cases
        var scanner: OptionScanner

        let subUserOptionString = "abx" // same for all three cases
        var subUser: JavaSubUser2
        var args: [String]
        
        // Case 1
        scanner = try! OptionScanner(optionString)
        subUser = JavaSubUser2(subUserOptionString, scanner)
        try! subUser.addSelfToScanner()
        args = ["prog", "-acx"]
        try! _ = scanner.getOpts(args)
        XCTAssert(subUser.someOptionsAreSet)
        
        // Case 2
        scanner = try! OptionScanner(optionString)
        subUser = JavaSubUser2(subUserOptionString, scanner)
        try! subUser.addSelfToScanner()
        args = ["prog", "-c"]
        try! _ = scanner.getOpts(args)
        XCTAssertFalse(subUser.someOptionsAreSet)
        
        // Case 3
        scanner = try! OptionScanner(optionString)
        subUser = JavaSubUser2(subUserOptionString, scanner)
        try! subUser.addSelfToScanner()
        args = ["prog", ""]
        try! _ = scanner.getOpts(args)
        XCTAssertFalse(subUser.someOptionsAreSet)
    }

}
