//
//  NameJavaTests.swift
//
//  This file combines the testing code, test input data and expected test
//  outputs for the Java class Name.java. The original files, in the directory
//  name/test, were TestName.java, test1.in and test1.expected.
//
//  Not all the Java tests are relevant, because of differences between the two
//. languages and also because of some relatively minor design choices. For
//  example, the Swift class does not have a copy constructor, and the major
//  properties of Swift instances are immutable, so we can't test set methods.
//
//  Created by Jim Clarke on 2021-11-21.
//

import XCTest
@testable import StringUtilities

class NameJavaTests: XCTestCase {
    
//    func testAreWeAlive () {
//        print("NameJavaTests is running")
//        XCTAssertTrue(true)
//    }
    
    // -- capitalize() --
    
    let capitalizeData = [
        "SMITH JOHN",
        "  MCDON JO BE",
        "DE VALERA E",
        "de valera e",
        "de valeRa e",
        "x de",
        "di x",
        "DI X",
        "di X",
        "Di x",
        "van x",
        "VAN X",
        "van X",
        "Van x",
        "von x",
        "VON X",
        "von X",
        "Von x",
        "mcdo",
        "MCDO",
        "mcdO",
        "mcDo",
        "mcmcdo",
        "macdo",
        "MACDO",
        "macdO",
        "macDo",
        "macMacDo",
        "fitzpa",
        "FITZPA",
        "fitzpA",
        "fitzPa",
    ]

    let capitalizeShouldBe = [
        "Smith John",
        "McDon Jo Be", // not "  McDon Jo Be" as in the Java tests,
        // because the Swift function standardizes whitespace
        "de Valera E", // Java: "De Valera E", because Java only lower-cases a
        // "noble" prefix if name has both cases and the prefix is already lower
        "de Valera E", // Java: "De Valera E"
        "de Valera E",
        "X De",
        "di X", // Java: "Di X", as with "de Valera E"
        "di X", // Java: "Di X"
        "di X",
        "di X", // Java: "Di X"
        "van X", // Java: "Van X"
        "van X", // Java: "Van X"
        "van X",
        "van X", // Java: "Van X"
        "von X", // Java: "Von X"
        "von X", // Java: "Von X"
        "von X",
        "von X", // Java: "Von X"
        "McDo",
        "McDo",
        "McDo",
        "McDo",
        "McMcdo",
        "Macdo",
        "Macdo",
        "Macdo",
        "Macdo", // Java: "MacDo", because Java treats Mac as special: if name has
        // both cases, and the original is upper-case, it is kept upper.
        "Macmacdo", // Java: "MacMacdo"
        "Fitzpa",
        "Fitzpa",
        "Fitzpa",
        "Fitzpa", // Java: "FitzPa", because Java treats Fitz like Mac
    ]
    
    func testCapitalize() {
        XCTAssert(capitalizeData.count == capitalizeShouldBe.count)
        for i in 0 ..< capitalizeData.count {
            let data = capitalizeData[i]
            let shouldBe = capitalizeShouldBe[i]
            let result = Name.capitalize(data)
            XCTAssertEqual(result, shouldBe, "data index \(i)")
        }
    }


    // -- familyToFront() --
    
    let familyToFrontData = [
        "Tom and Mary",
        "Tom and  Mary",
        "Tom and\t\tMary",
        "Tom and Mary ",
        "Tom  and Mary",
        " Tom and Mary",
        "Tom",
        " Tom",
        " Tom ",
        "Tom ",
        "Tom and",
        "",
        " ",
        "\t",
        "s",
        "  ",
        "\t\t",
        "s ",
        " s",
        "st",
        "   ",
        " st",
        "s t",
        "st ",
        "s  ",
        " s ",
        "\ts\t",
        "  s",
        "  s t  ",
    ]

    let familyToFrontShouldBe = [
        "Mary Tom and",
        "Mary  Tom and",
        "Mary\t\tTom and",
        "Mary Tom and",
        "Mary Tom  and",
        "Mary Tom and",
        "Tom",
        "Tom",
        "Tom",
        "Tom",
        "and Tom",
        "",
        "",
        "",
        "s",
        "",
        "",
        "s",
        "s",
        "st",
        "",
        "st",
        "t s",
        "st",
        "s",
        "s",
        "s",
        "s",
        "t s",
    ]

    func testFamilyToFront() {
        XCTAssert(familyToFrontData.count == familyToFrontShouldBe.count)
        for i in 0 ..< familyToFrontData.count {
            let data = familyToFrontData[i]
            let shouldBe = familyToFrontShouldBe[i]
            let result = Name.familyToFront(data)
            XCTAssertEqual(result, shouldBe, "data index \(i)")
        }
    }


    // -- check() --
    
    let checkData = [
        "hi there",
        "fred big-shot",
        "pat o'malley",
        "(jim) james T. mcnally",
        "",
        " ",
        "  ",
        "   ",
        "\t",
        "james[jim]",
        "james(jim)",
        "#$%^&",
    ]

    let checkShouldBe = [
        "yes",
        "yes",
        "yes",
        "yes",
        "yes",
        "yes",
        "yes",
        "yes",
        "yes",
        "no",
        "yes",
        "no",
    ]

    func testCheck() {
        XCTAssert(checkData.count == checkShouldBe.count)
        for i in 0 ..< checkData.count {
            let data = checkData[i]
            let shouldBe = checkShouldBe[i]
            let result = Name.check(name: data) ? "yes" : "no"
            XCTAssertEqual(result, shouldBe, "data index \(i)")
        }
    }


    // -- constructors --

    let constructorsData = [
        "SMITH JOHN",
        "  MCDON JO BE  ",
        "MCDON JO BE",
        "MCDON\tJO\tBE",
        "smith jones  jim",
        "smith  jones  jim",
        "smith jones,jim",
        "smith,jones  jim",
        "smith jones , jim",
        "smith , jones  jim",
        "smith jones jim",
        "  O'BRIAN ROSIE",
        "",
        " ",
        "\t",
        "s",
        "  ",
        "\t\t",
        "s ",
        " s",
        "st",
        " st",
        "s t",
        "st ",
        "s  ",
        " s ",
        "\ts\t",
        "  s",
        "  s t  ",
        "s tabbed\tu",
        "u  t",
        "u  t ",
        " u t",
        "u t ",
        " u t ",
        "abcdef",
        "u,t",
        "u, t",
        ",u,t",
        "u, t",
        "u ,t",
        "u,t,",
    ]

    let constructorsShouldBe = [
        // no arguments: "" // Swift version has no no-arg constructor
        ["Smith  John", "Smith John"],
        ["McDon  Jo Be", "McDon Jo Be"],
        ["McDon  Jo Be", "McDon Jo Be"],
        ["McDon  Jo Be", "McDon Jo Be"],
        ["Smith Jones  Jim", "Smith Jones Jim"],
        ["Smith  Jones Jim", "Smith Jones Jim"],
        ["Smith Jones  Jim", "Smith Jones Jim"],
        ["Smith  Jones Jim", "Smith Jones Jim"],
        ["Smith Jones  Jim", "Smith Jones Jim"],
        ["Smith  Jones Jim", "Smith Jones Jim"],
        ["Smith  Jones Jim", "Smith Jones Jim"],
        ["O'Brian  Rosie", "O'Brian Rosie"],
        ["", ""],
        ["", ""],
        ["", ""],
        ["S", "S"],
        ["", ""],
        ["", ""],
        ["S", "S"],
        ["S", "S"],
        ["St", "St"],
        ["St", "St"],
        ["S  T", "S T"],
        ["St", "St"],
        ["S", "S"],
        ["S", "S"],
        ["S", "S"],
        ["S", "S"],
        ["S  T", "S T"],
        ["S Tabbed  U", "S Tabbed U"],
        ["U  T", "U T"],
        ["U  T", "U T"],
        ["U  T", "U T"],
        ["U  T", "U T"],
        ["U  T", "U T"],
        ["Abcdef", "Abcdef"],
        ["U  T", "U T"],
        ["U  T", "U T"],
        ["U T", "U T"],  // first result is "U T" in Swift, not "  U T",
            // because Swift constructor replaces empty family name with given
            // names
        ["U  T", "U T"],
        ["U  T", "U T"],
        ["U  T", "U T"],
    ]

    func testConstructors() {
        XCTAssert(constructorsData.count == constructorsShouldBe.count)
        for i in 0 ..< constructorsData.count {
            let data = constructorsData[i]
            let shouldBe0 = constructorsShouldBe[i][0]
            let shouldBe1 = constructorsShouldBe[i][1]
            let n0 = Name(name: data)
            let result0 = "\(n0)"
            let n1 = Name(familyName: data, givenNames: "")
            let result1 = "\(n1)"
            XCTAssertEqual(result0, shouldBe0, "data index \(i)")
            XCTAssertEqual(result1, shouldBe1, "data index \(i)")
        }
    }


    // -- "get methods"; "set methods" not provided in Swift version --

    let getNoSetData = [
        "",
        "smith bill",
        "rubble barney alastair",
    ]

    let getNoSetShouldBe = [
        ["", "", "", ""], // not the no-name constructor, but the empty name
        ["Smith  Bill", "Smith", "Bill", "smith  bill"],
        ["Rubble  Barney Alastair", "Rubble", "Barney Alastair",
            "rubble  barney alastair"],
    ]

    func testGetNoSet() {
        XCTAssert(getNoSetData.count == getNoSetShouldBe.count)
        for i in 0 ..< getNoSetData.count {
            let data = getNoSetData[i]
            let name = Name(name: data)
            let shouldBe0 = getNoSetShouldBe[i][0]
            let shouldBe1 = getNoSetShouldBe[i][1]
            let shouldBe2 = getNoSetShouldBe[i][2]
            let shouldBe3 = getNoSetShouldBe[i][3]
            let result0 = "\(name)"
            let result1 = name.familyName
            let result2 = name.givenNames
            let result3 = name.normalForm
            XCTAssertEqual(result0, shouldBe0, "data index \(i)")
            XCTAssertEqual(result1, shouldBe1, "data index \(i)")
            XCTAssertEqual(result2, shouldBe2, "data index \(i)")
            XCTAssertEqual(result3, shouldBe3, "data index \(i)")
        }
    }


    // -- copy() --
    
    // Copy constructors aren't a thing in Swift; you can just assign the old
    // object to the new object, and if it's a reference, you get the usual
    // same-thing results.
    
    // And if we did have a copy constructor, we couldn't do something like the
    // Java tests on the copy-constructor results, because the instance
    // properties are constants.


    // -- equals(), compareTo(); hashCode() not needed in Swift  --

    let comparingData = [
        "",
        "a",
        "z",
        "m",
        "(",
        "[",
        "{",
    ]

    let comparingShouldBe = [
        ["true",  "0", "false", "-1", "false", "-1", "false", "-1"],
        ["false", "1", "false", "1", "true", "0", "false", "-1"],
        ["false", "1", "false", "1", "false", "1", "true", "0"],
        ["false", "1", "false", "1", "false", "1", "false", "-1"],
        ["false", "1", "false", "-1", "false", "-1", "false", "-1"], // not the
            // same as the Java tests, because "very early" is "0" and not " "
        ["false", "1", "false", "1", "false", "-1", "false", "-1"],
        ["false", "1", "false", "1", "false", "1", "false", "1"],
    ]

    func testComparing() {
        
        func uniComp(_ left: Name, _ right: Name) -> Int {
            return left < right ? -1 : left > right ? +1 : 0
        }
        
        XCTAssert(comparingData.count == comparingShouldBe.count)
        let empty = Name(name: "")
        let veryEarly = Name(name: "0")
        let early = Name(name: "a")
        let late = Name(name: "z")
        for i in 0 ..< comparingData.count {
            let data = Name(name: comparingData[i])
            let shouldBe = comparingShouldBe[i]
            var results = [String]()
            for other in [empty, veryEarly, early, late] {
                results.append(String(data == other))
                results.append(String(uniComp(data, other)))
            }
            XCTAssertEqual(results, shouldBe, "data index \(i)")
        }
    }

}
