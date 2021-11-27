//
//  Name.swift
//
//  Format and compare people's names. Mostly based on a Java version from 2003,
//  itself based on a C version with some code inherited from a Turing function.
//
//  The only significant difference between the Java version and this one is
//  that here, the name is immutable (and all derived values are prepared when
//  the Name object is created. If you want a new name, make a new Name.
//
//  As I am the only known user of the Name class, I don't think the differences
//  will cause trouble.
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
    
    // A Name represents a person's name. A name is considered to consist of two
    // parts: a family name and some given names. There are two init() methods,
    // allowing a Name to be created either from two strings specifying the
    // family and given names, or from a single string assumed to consist of the
    // family name followed by the given names.
    //
    // The properties of a Name include all three values:
    // 1) name: a single String combining the family and given names
    // 2) familyName
    // 3) givenNames
    // All are public but (unlike in the Java version) not modifiable. If you
    // want a different name, make a new Name.
    //
    // There is also a non-public "normal form", used in comparisons.
    //
    // There are two init() methods. One init() takes name (1) and breaks it
    // up into (2) and (3) using plausible rules. The other init() takes (2)
    // and (3) and concatenates them to make (1). After the Name is created, the
    // caller can assume all three parts are available (but not changeable).
    //
    // Before storing, we clean up the name in all three versions: capitalizing
    // (with the static method capitalize()) and fixing up blanks with
    // standardize(). Some people may be unhappy with this, but enough people
    // are surprisingly casual with their names that to make printed output
    // bearable we need to be the uncasual ones.


    // non-static members first

    // the parts that matter
    
    public let name: String // did not exist in Java version
    public let familyName: String
    public let givenNames: String
    let normalForm: String // all lower case, for comparison and equality checks

    
    // Create a Name from a single String giving the entire name.
    //
    // The parameter "name" is reconstructed and cleaned up before it is saved
    // as the instance property "name" (in the other ("designated") init()).
    
    public convenience init(name: String) {
        // Can't call standardize() yet, because it makes word separators into
        // single blanks.

        let (familyName, givenNames) = Name.dissectName(name)
        
        self.init(familyName: familyName, givenNames: givenNames)
    }


    // Create a Name from supplied familyName and givenNames.
    //
    // The parameters are cleaned up before they are used to build the instance
    // properties.
    
    public init(familyName: String, givenNames: String) {
        let cleanedFamily = Name.standardize(Name.capitalize(familyName))
        let cleanedGiven = Name.standardize(Name.capitalize(givenNames))
        
        if cleanedFamily.isEmpty {
            self.familyName = cleanedGiven
            self.givenNames = ""
        } else {
            self.familyName = cleanedFamily
            self.givenNames = cleanedGiven
        }
        
        if self.givenNames.isEmpty {
            self.name = self.familyName
        } else {
            self.name = self.familyName + "  " + self.givenNames
        }
        normalForm = self.name.lowercased()
    }


    // static members
    
    static let SEPARATOR: String = "," // not Character because it's used in a
    // [String] in dissectName().
    
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


    // Extract and return the two parts of name: family name and given names.
    //
    // On return, either or both of familyName and givenNames may be "". The
    // caller will want to handle the situation where just familyName is empty.
    //
    // The process is vulnerable to malicious use of commas or tabs or even
    // blanks in sufficient numbers, but if people want to type their names like
    // that....
    //
    // If the family name is in last position instead of first, try reversing
    // the name, dissecting it, and re-reversing the two return values. (Don't
    // forget that reversed strings need casting to make them into Strings.)
    // This kludge will fail if the separator is a non-palindrome -- which none
    // are at present.

    public static func dissectName(_ name: String) -> (String, String) {
        
        let trimmed = trimWhitespace(name)
            // because leading or trailing blanks might mislead us
            
        var familyName: String?
        var givenNames: String?
        let separators = [SEPARATOR, "  ", "\t", " "] // The order matters.
        
        for sep in separators {
            // Nov. 2021: The String method
            //      range(of: String) -> Range
            // seems to be new, perhaps as recently as Swift 5.5 (out for
            // perhaps half a year now). Previously you had to use the NSString
            // method
            //      range(of: String) -> NSRange
            // and then use one of Range's initializers:
            //      Range(NSRange, in: String)
            // It was a relief to find String's new range(), but some
            // documentation would have been nice.
            
            if let sepRange = trimmed.range(of: sep) {
                let breakpoint = sepRange.lowerBound
                familyName = String(trimmed[trimmed.startIndex ..< breakpoint])
                
                let afterBreak = sepRange.upperBound
                if afterBreak >= trimmed.endIndex {
                    // could happen if sep is a trailing "," or something else
                    // that is not cleaned up by trimming
                    givenNames = ""
                } else {
                    givenNames =
                            String(trimmed[afterBreak ..< trimmed.endIndex])
                    // can't be nil: substring is not empty
                    // can't be "" ... if I'm right. It's OK if I'm wrong.
                }
                // givenNames is not nil here
                
                givenNames = trimWhitespace(givenNames!) // might be empty now
                
                break // from loop
            }
        }
        
        // If familyName is not nil, then we found a separator, so givenNames is
        // also not nil.
        
        if familyName == nil {
            // We didn't find a separator.
            familyName = name
            givenNames = ""
        }
        
        return (familyName!, givenNames!)
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
    
    
	// Return name, capitalized in an often-acceptable way.
    //
    // Non-whitespace characters are changed only in their case. If the name
    // parameter has mixed case, the capitalization is "clever" but certainly
    // not always right. We try to work with appropriate respect for people's
    // names, but perfection is unavailable.
    //
    // As for the whitespace characters, the first step is to call
    // standardize(name), so that we can assume all parts of the name are
    // separated by single blanks, without leading or trailing blanks. This
    // means that if you want to use spacing information to identify the family
    // name, you have to do that before this function is called.
    
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
            
            // Prepare to apply later fixes.
            var capitalizeFirstChar = true
            
            // Letters after a hyphen are capitalized -- always, but only for
            // the first hyphen. This happens towards the end of this function.
                        
            // We can manage to capitalize one other internal character. Any
            // more and the code needs rethinking.
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
            } else if loweredWord.starts(with: "o'") && word.count > 2 {
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
            
            // Lower-case the whole word, then start capitalizing.
            
            // Generally, the first letter is capitalized in the next step.
            word = loweredWord
               
            if capitalizeFirstChar {
                let firstChar = word.removeFirst()
                word.insert(contentsOf: firstChar.uppercased(),
                            at: word.startIndex)
            }
            
            // Letters after hyphens are capitalized.
            
            var hyphenIndex = word.firstIndex(of: "-")
            if hyphenIndex != nil {

            print("found hyphen in \"\(word)\"")
            }

            if hyphenIndex != nil
                // Is there space for a letter after the hyphen?
               && hyphenIndex! < word.index(word.endIndex, offsetBy: -1)
            {
                print("found hyphen 2 in \"\(word)\"")
                print("hyphen is \"\(word[hyphenIndex!])\"")
                let afterHyphenIndex = word.index(hyphenIndex!, offsetBy: 1)
                let afterHyphen = word.remove(at: afterHyphenIndex)
                print("afterHyphen is \"\(afterHyphen)\"")
                print("letter k should be \"\(word[word.index(word.startIndex, offsetBy: 3)])\"")
                word.insert(contentsOf: afterHyphen.uppercased(),
                            at: afterHyphenIndex)
                print("now word is \"\(word)\"")
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


