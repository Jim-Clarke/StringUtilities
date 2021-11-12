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
            let after = Name.standardize(before)
            let shouldbe = standardizeTests[i][1]
            XCTAssertEqual(after, shouldbe)
        }
    }
    
    let capitalizeTests = [
        ["jim!", "Jim!"],
        ["  hi my.  name is,jim, ", "Hi My. Name Is Jim"],
        ["h\ti", "H I"],
        ["\ttab\t2tabs\t\tendtabs\t\t\t", "Tab 2tabs Endtabs"],
        [",ab,,cd,, ,ef,, ,", "Ab Cd Ef"],
        ["John von Neumann", "John von Neumann"],
        ["John Von Neumann", "John Von Neumann"],
        ["JOHN VON NEUMANN", "John Von Neumann"],
        ["john von neumann", "John Von Neumann"],
        ["Gérard de Vaucouleurs", "Gérard de Vaucouleurs"],
        ["Gerard de", "Gerard De"],
        ["ian mcdonald", "Ian McDonald"],
        ["ian mc", "Ian Mc"],
        ["Ian macdonald", "Ian Macdonald"],
        ["Ian macDonald", "Ian MacDonald"],
        ["Ian mac", "Ian Mac"],
        ["Roy fitzallan", "Roy Fitzallan"],
        ["Roy FITZALLAN", "Roy FitzAllan"],
        ["Roy FITZ", "Roy Fitz"],

    ]
    
    func testCapitalize() {
        for i in 0 ..< capitalizeTests.count {
            let before = capitalizeTests[i][0]
            let after = Name.capitalize(before)
            let shouldbe = capitalizeTests[i][1]
            XCTAssertEqual(after, shouldbe)
        }
    }
    
    
    let familyToFrontTests = [
        ["", ""],
        ["  ", ""],
        [" jim ", "jim"],
        ["jim!", "jim!"],
        ["  Isaac  Newton  ", "Newton  Isaac"],
        ["\t\tAlbert\t\t\t Einstein and \t\t\t\t Company\t\t ",
            "Company \t\t\t\t Albert\t\t\t Einstein and"],

    ]
    
    func testFamilyToFront() {
        for i in 0 ..< familyToFrontTests.count {
            let before = familyToFrontTests[i][0]
            let after = Name.familyToFront(before)
            let shouldbe = familyToFrontTests[i][1]
            XCTAssertEqual(after, shouldbe)
        }
    }
}
