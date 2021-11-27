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
    
    func testAreWeAlive () {
//        print("NameJavaTests is running")
//        XCTAssertTrue(true)
    }
    
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
        // because the Swift function standardizes white space
        "De Valera E",
        "De Valera E",
        "de Valera E",
        "X De",
        "Di X",
        "Di X",
        "di X",
        "Di X",
        "Van X",
        "Van X",
        "van X",
        "Van X",
        "Von X",
        "Von X",
        "von X",
        "Von X",
        "McDo",
        "McDo",
        "McDo",
        "McDo",
        "McMcdo",
        "Macdo",
        "Macdo",
        "Macdo",
        "MacDo",
        "MacMacdo",
        "Fitzpa",
        "Fitzpa",
        "Fitzpa",
        "FitzPa",
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




}


//=======
//=======


/* Java input data START

quit
quit

smith bill
rubble barney alastair
quit

smith bill
quit

a
z
m
(
[
{
quit

-- END Java input data
*/

/* Java expected test results START

-- capitalize() --
-- familyToFront() --
-- check() --
-- constructors --
-- get and set methods --
"": "" "" "" "Backus" "Backus" "" "Backus  Ada Alan" "Backus" "Ada Alan"
"smith bill": "Smith  Bill" "Smith" "Bill" "Backus  Bill" "Backus" "Bill" "Backus  Ada Alan" "Backus" "Ada Alan"
"rubble barney alastair": "Rubble  Barney Alastair" "Rubble" "Barney Alastair" "Backus  Barney Alastair" "Backus" "Barney Alastair" "Backus  Ada Alan" "Backus" "Ada Alan"
-- copy() --
"": "" "" "x" "" "x" "  y"
"smith bill": "Smith  Bill" "Smith  Bill" "x  Bill" "Smith  Bill" "x  Bill" "Smith  y"
-- equals(), hashCode(), compareTo() --
"": 17 true 0 false -1 false -1 false -1
"a": 3606 false 1 false 1 true 0 false -1
"z": 4531 false 1 false 1 false 1 true 0
"m": 4050 false 1 false 1 false 1 false -1
"(": 1497 false 1 false 1 false -1 false -1
"[": 3384 false 1 false 1 false -1 false -1
"{": 4568 false 1 false 1 false 1 false 1

-- END Java expected test results
*/

/*  Java code START

		// Test overall name construction and conversion.
		System.out.println("-- constructors --");
		{
			Name n1 = new Name();
			System.out.print("no arguments: ");
			System.out.print("\"" + n1.toString() + "\"");
			System.out.println();
		}
		while (true) {
			String s = in.readLine();
			if (s.equals("quit"))
				break;
			Name n1 = new Name(s);
			Name n2 = new Name(s, "");
			System.out.print("\"" + s + "\": ");
			System.out.print("\"" + n1.toString() + "\"");
			System.out.println(" \"" + n2.toString() + "\"");
		}

		// Test get and set methods.
		System.out.println("-- get and set methods --");
		while (true) {
			String s = in.readLine();
			if (s.equals("quit"))
				break;
			System.out.print("\"" + s + "\": ");
			Name n1 = new Name(s);
			System.out.print("\"" + n1.toString() + "\"");
			System.out.print(" \"" + n1.getFamilyName() + "\"");
			System.out.print(" \"" + n1.getGivenNames() + "\"");
			n1.setFamilyName("Backus");
			System.out.print(" \"" + n1.toString() + "\"");
			System.out.print(" \"" + n1.getFamilyName() + "\"");
			System.out.print(" \"" + n1.getGivenNames() + "\"");
			n1.setGivenNames("Ada Alan");
			System.out.print(" \"" + n1.toString() + "\"");
			System.out.print(" \"" + n1.getFamilyName() + "\"");
			System.out.print(" \"" + n1.getGivenNames() + "\"");
			System.out.println();
		}

		// Test copy().
		System.out.println("-- copy() --");
		while (true) {
			String s = in.readLine();
			if (s.equals("quit"))
				break;
			System.out.print("\"" + s + "\": ");
			Name n1 = new Name(s);
			System.out.print("\"" + n1.toString() + "\"");
			Name n2 = n1.copy();
			System.out.print(" \"" + n2.toString() + "\"");
			n1.setFamilyName("x");
			System.out.print(" \"" + n1.toString() + "\"");
			System.out.print(" \"" + n2.toString() + "\"");
			n2.setGivenNames("y");
			System.out.print(" \"" + n1.toString() + "\"");
			System.out.print(" \"" + n2.toString() + "\"");
			System.out.println();
		}

		// Standard names for comparison testing.
		final Name empty = new Name("");
		final Name veryEarly = new Name("", "a");
		final Name early = new Name("a");
		final Name late = new Name("z");

		// Test equals(), hashCode() and compareTo().
		System.out.println("-- equals(), hashCode(), compareTo() --");
		while (true) {
			String s = in.readLine();
			if (s.equals("quit"))
				break;
			System.out.print("\"" + s + "\": ");
			Name n1 = new Name(s);
			System.out.print(n1.hashCode());
			System.out.print(" " + n1.equals(empty)
					+ " " + uni(n1.compareTo(empty)));
			System.out.print(" " + n1.equals(veryEarly)
					+ " " + uni(n1.compareTo(veryEarly)));
			System.out.print(" " + n1.equals(early)
					+ " " + uni(n1.compareTo(early)));
			System.out.print(" " + n1.equals(late)
					+ " " + uni(n1.compareTo(late)));
			System.out.println();
		}
	}

	/**
	 * Return compareTo()'s output, standardized to +1, 0, -1.
	 * @param i	A value received from compareTo().
	 * @return int	The parameter, standardized.
	 */
	private static int uni(int i) {
		if (i < 0)
			return -1;
		else if (i > 0)
			return +1;
		else
			return 0;
	}

-- END Java code
*/
