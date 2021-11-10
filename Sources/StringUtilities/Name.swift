//
//  Name.swift
//
//  Format and compare people's names. Mostly based on a Java version from 2003,
//  itself based on a C version with some code inherited from a Turing function.
//  
//
//  Created by Jim Clarke on 2021-07-30.
//

import Foundation



extension Name : CustomStringConvertible {
    public var description: String {
        if givenNames.isEmpty {
            return familyName
        } else {
            return familyName + "  " + givenNames
        }
    }
}

extension Name: Equatable {
    public static func == (one: Name, two: Name) -> Bool {
        return one.normalForm == two.normalForm
    }
}

extension Name: Comparable {
    public static func < (one: Name, two: Name) -> Bool {
        return one.normalForm < two.normalForm
    }
}


public class Name {
    
    // static members first
    
    public static func testing() -> String {
        return "hi, mom"
    }
    
    static let SEPARATOR: Character = ","// TODO: String?
    
    // Characters other than letters and whitespace that are allowed in a name.
    // The collection may change as experience accumulates. It is used only in
    // check().
    static let extraCharacters = CharacterSet(charactersIn: ".-'()")
    
    static let allowedCharacters =
        CharacterSet.letters.union(.whitespaces).union(extraCharacters)
        
    // Return true iff all characters in name are allowed in a name. This
    // utility function is offered to users but not called in any other method
    // here, as of May 2003 (and August 2021!).
    public static func check(name: String) -> Bool {
        for char in name {
            guard let unicodeChar = Unicode.Scalar(String(char)) else {
                return false
            }
            if !allowedCharacters.contains(unicodeChar) {
                return false
            }
        }
        return true
    }
    

    // Return name * converted into standard form:
    // - all whitespace and SEPARATORs converted to blanks
    // - leading and trailing whitespace removed
    // - all sequences of blanks converted to single blanks.
    
    // * presumably either a family or a given name, since we ignore
    // formatting that would distinguish those parts.
    
    public static func standardize(name: String) -> String {
        let BLANK: Character = " "
        var result = name
        
        // Convert all non-blank whitespace and SEPARATORs to blanks:

        // First, make a set of the characters that are to become blanks.
        var toBeBlanked = CharacterSet.whitespaces
        toBeBlanked.remove(charactersIn: String(BLANK))
        toBeBlanked.insert(charactersIn: String(SEPARATOR))

        // Secondly, replace them all with blanks.
        for char in name {
            let code = Unicode.Scalar(String(char))
            if code == nil || !toBeBlanked.contains(code!) {
                continue
            }
            let location = result.firstIndex(of: char)
            if location != nil {
                result.remove(at: location!)
                result.insert(BLANK, at: location!)
            }
        }

        // Get rid of leading and trailing whitespace.
        result = trimWhitespace(result)

        // Get rid of pairs of blanks forever.
        while result.contains("  ") {
            result = result.replacingOccurrences(of: "  ", with: " ")
        }
        
        return result
    }

    
    // non-static members
    
    // When a name is created, it is broken up into family-name and given-names
    // parts.
    
    let familyName: String
    let givenNames: String
    let normalForm: String // used in comparison and equality checks
    
    var name: String
    
    init(name: String) {
        self.name = name
        familyName = name
        givenNames = name
        normalForm = name
    }
}
