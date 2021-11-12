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
            let unicodeChar = Unicode.Scalar(String(char))
            if unicodeChar == nil || !allowedCharacters.contains(unicodeChar!) {
                return false
            }
        }
        return true
    }
    

    // Return name(*) converted into standard form:
    // - all whitespace and SEPARATORs converted to blanks
    // - leading and trailing whitespace removed
    // - all sequences of blanks converted to single blanks.
    
    // * presumably either a family or a given name, since we ignore
    // formatting that would distinguish those parts.
    
    public static func standardize(_ name: String) -> String {
        let BLANK: Character = " "
        var result = name
        
        // Convert all non-blank whitespace and SEPARATORs to blanks:

        // First, make a set of the characters that are to become blanks.
        var toBeBlanked = CharacterSet.whitespaces
        toBeBlanked.remove(charactersIn: String(BLANK))
        toBeBlanked.insert(charactersIn: String(SEPARATOR))

        // Secondly, replace them all with blanks.
        for char in name {
            let unicodeChar = Unicode.Scalar(String(char))
            if unicodeChar == nil || !toBeBlanked.contains(unicodeChar!) {
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
    
    
	// Return name, capitalized in an often-acceptable way. Makes no changes
	// except to the case of letters; in particular, does not change the length
	// or spacing of name. Behaves more "cleverly" if name originally has mixed
	// case, but is certainly not always right.
    //
    // The first step is to call standardize(name), so that we can assume all parts
    // of the name are separated by single blanks, without leading or trailing
    // blanks. This means that before this function is called, the name should
    // already have been broken into separate family and given names.
    
    public static func capitalize(_ name: String) -> String {
        // Which cases are present in the name?
        var charsInName = CharacterSet()
        charsInName.insert(charactersIn: name)
        
        let nameHasLowers = !charsInName
            .intersection(CharacterSet.lowercaseLetters).isEmpty
        let nameHasUppers = !charsInName
            .intersection(CharacterSet.uppercaseLetters).isEmpty
        let nameHasBothCases = nameHasLowers && nameHasUppers
        
        // Standardize the name: make the "word" separators all single blanks,
        // with no leading or trailing blanks. Then break it into separate
        // words. (There may be non-blank word separators that are made into
        // blanks by standardize().)
        let words = standardize(name).split(separator: " ")
        
        // Capitalize each word of the name and append it to fixedWords.
        var fixedWords = [Substring]()
        for i in 0 ..< words.count {
            var word = words[i]
            let loweredWord = Substring(word.lowercased())
            
            var capitalizeFirstChar = true
            // One internal character can be capitalized.
            var internalCapIndex = -1
            
            // Is the word a prefix indicating noble descent?
            let noblePrefixes: [Substring] = ["de", "di", "van", "von"]
            if nameHasBothCases
                && noblePrefixes.contains(word)
                // Ignore this rule on the last word in the name, so as to
                // avoid (e.g.) leaving a truncated "Dennis" uncapitalized.
                && i < words.count - 1
            {
                capitalizeFirstChar = false
            }
            
            // Look for parentage-related prefixes (internal to word)
            // that might have required or permitted capitalization.
            // Required:
            if loweredWord.starts(with: "mc") && word.count > 2 {
                internalCapIndex = 2
            }
            // Permitted, and we'll keep the original capitalization if
            // name has both cases:
            if nameHasBothCases {
                var maybeCapIndex = -1
                
                if loweredWord.starts(with: "mac") {
                    maybeCapIndex = 3
                } else if loweredWord.starts(with: "fitz") {
                    maybeCapIndex = 4
                }
                
                // Check original capitalization.
                if maybeCapIndex > 0 && maybeCapIndex < word.count {
                    let location = word.index(word.startIndex,
                                              offsetBy: maybeCapIndex)
                    if word[location].isUppercase {
                        internalCapIndex = maybeCapIndex
                    }
                }
            }
            
            // Lower-case the whole word. Generally, the first letter will
            // be capitalized in the next step.
            word = Substring(word.lowercased())
               
            if capitalizeFirstChar {
                let firstChar = word.removeFirst()
                word.insert(contentsOf: firstChar.uppercased(),
                            at: word.startIndex)
            }
            
            if internalCapIndex > 0 {
                let location = word.index(word.startIndex,
                                          offsetBy: internalCapIndex)
                let nthChar = word.remove(at: location)
                word.insert(contentsOf: nthChar.uppercased(), at: location)
            }
            
            fixedWords.append(word)
        }
        
        // Put the capitalized words together again.
        var result = ""
        for word in fixedWords {
            result += " " + word
        }
        // Drop the leading blank.
        result = trimWhitespace(result)
        
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


    // Return name with the family-name part moved to the beginning -- that is,
    // move the last word of the name to the beginning, where it is separated
    // by at least one whitespace character from the rest of the name. Double
    // blanks that might attempt to designate more than the last word as the
    // "family name" are ignored, but the last whitespace sequence before the
    // family name is preserved and inserted after the family name in the
    // string returned.
    //
    // Leading and trailing whitespace is removed. If there is no internal
    // whitespace, or if there is any kind of trouble, the name is returned
    // unchanged except for removal of any leading or trailing whitespace.
    //
    // This function is not exactly deprecated, but I have never actually used
    // it. It differs from the Java implementation in that it handles general
    // whitespace rather than (sometimes!) blanks specifically.
    
    public static func familyToFront(_ name: String) -> String {
        var result = trimWhitespace(name)
        if result.isEmpty {
            return result
        }
        
        func isWhitespace(_ c: Character) -> Bool {
            CharacterSet.whitespaces.contains(Unicode.Scalar(String(c))!)
        }
        
        func isNotWhitespace(_ c: Character) -> Bool {
            !isWhitespace(c)
        }

        // Find the last whitespace.
        let lastBlankIndex = result.lastIndex(where: isWhitespace)
        if lastBlankIndex == nil {
            // There was no internal whitespace.
            return result
        }
        
        // Extract and remove the family name.
        let familyFirstIndex = result.index(lastBlankIndex!, offsetBy: 1)
        let familyName = result[familyFirstIndex ..< result.endIndex]
        result.removeSubrange(familyFirstIndex ..< result.endIndex)
        
        // Find where the last whitespace sequence starts, extract it, and
        // remove it.
        let lastNonBlankIndex = result.lastIndex(where: isNotWhitespace)
        if lastNonBlankIndex == nil {
            // Should not happen. Oh, well.
            return result + familyName
        }
        let lastBlanksStartIndex = result.index(lastNonBlankIndex!,
                                                offsetBy: 1)
        let separatingWhitespace =
                result[lastBlanksStartIndex ..< result.endIndex]
        result.removeSubrange(lastBlanksStartIndex ..< result.endIndex)
        
        // And the name is ...
        result = familyName + separatingWhitespace + result

        return result
    }

}


