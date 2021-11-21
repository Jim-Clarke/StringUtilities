//
//  NameTests.swift
//  
//
//  Created by Jim Clarke on 2021-07-30.
//

import XCTest
@testable import StringUtilities

class NameTests: XCTestCase {

    let init1Tests = [
        ["Jim", "Jim", "Jim", "", "jim"],
        [", Jim", "Jim", "Jim", "", "jim"],
        ["Clarke  Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke,Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke, Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke\tJim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke ,Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke,  Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke,    Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        [".cummings,.e .e", ".cummings  .e .e", ".cummings", ".e .e", ".cummings  .e .e"],
        ["=cummings,\'e $e", "=cummings  'e $e", "=cummings", "'e $e", "=cummings  'e $e"], // or any non-letter of the user's preference
    ]
    
    func testInit1() {
        for i in 0 ..< init1Tests.count {
            let nameData = init1Tests[i][0]
            let expName = init1Tests[i][1]
            let expFamily = init1Tests[i][2]
            let expGiven = init1Tests[i][3]
            let expNorm = init1Tests[i][4]
            
            let name = Name(name: nameData)
            XCTAssertEqual(name.name, expName, "name")
            XCTAssertEqual(name.familyName, expFamily, "family")
            XCTAssertEqual(name.givenNames, expGiven, "given")
            XCTAssertEqual(name.normalForm, expNorm, "normal")
        }
    }
    
    let init2Tests = [
        ["Jim", "", "Jim", "Jim", "", "jim"],
        ["", "Jim", "Jim", "Jim", "", "jim"],
        ["Clarke    ", "Jim", "Clarke  Jim", "Clarke", "Jim", "clarke  jim"],
        ["Clarke", "Jim   Bob", "Clarke  Jim Bob", "Clarke", "Jim Bob", "clarke  jim bob"],
        ["Clarke", "Jim,,Bob", "Clarke  Jim Bob", "Clarke", "Jim Bob", "clarke  jim bob"],
        [".cummings", ".e .e", ".cummings  .e .e", ".cummings", ".e .e", ".cummings  .e .e"],
   ]
    
    func testInit2() {
        for i in 0 ..< init2Tests.count {
            let familyNameData = init2Tests[i][0]
            let givenNamesData = init2Tests[i][1]
            let expName = init2Tests[i][2]
            let expFamily = init2Tests[i][3]
            let expGiven = init2Tests[i][4]
            let expNorm = init2Tests[i][5]
            
            let name = Name(familyName: familyNameData,
                            givenNames: givenNamesData)
            XCTAssertEqual(name.name, expName, "name")
            XCTAssertEqual(name.familyName, expFamily, "family")
            XCTAssertEqual(name.givenNames, expGiven, "given")
            XCTAssertEqual(name.normalForm, expNorm, "normal")
        }
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
    
    
    let dissectNameTests = [
        ["Jim", "Jim", ""],
        [", Jim", "", "Jim"],
        ["Clarke  Jim", "Clarke", "Jim"],
        ["Clarke,Jim", "Clarke", "Jim"],
        ["Clarke, Jim", "Clarke", "Jim"],
        ["Clarke\tJim", "Clarke", "Jim"],
        ["Clarke Jim", "Clarke", "Jim"],
        ["Clarke ,Jim", "Clarke ", "Jim"],
        ["Clarke,  Jim", "Clarke", "Jim"],
        ["Clarke,    Jim", "Clarke", "Jim"],
        ["Clarke,Jim, Bob", "Clarke", "Jim, Bob"],
        ["Clarke,Jim,,,,,Bob", "Clarke", "Jim,,,,,Bob"],
        [".cummings,.e .e", ".cummings", ".e .e"],
        ["=cummings,\'e $e", "=cummings", "'e $e"], // or any non-letter of the user's preference
    ]
    
    func testDissectName() {
        for i in 0 ..< dissectNameTests.count {
            let before = dissectNameTests[i][0]
            let (family, givens) = Name.dissectName(before)
            let shouldbeFamily = dissectNameTests[i][1]
            let shouldbeGivens = dissectNameTests[i][2]
            XCTAssertEqual(family, shouldbeFamily)
            XCTAssertEqual(givens, shouldbeGivens)
        }
    }
    
    
    // Try getting family name when it's in last position.
    func testLastDissectName() {
        let name = "Jim Bob  Clarke"
        let rev = String(name.reversed())
        let (revFamily, revGivens) = Name.dissectName(rev)
        let family = String(revFamily.reversed())
        let givens = String(revGivens.reversed())
        let shouldbeFamily = "Clarke"
        let shouldbeGivens = "Jim Bob"
        XCTAssertEqual(family, shouldbeFamily)
        XCTAssertEqual(givens, shouldbeGivens)
    }
}
