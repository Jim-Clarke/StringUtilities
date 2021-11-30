//
//  Name.swift
//
//  Keep people's names in a standard form, formatted consistently and ready for
//  comparison with other names.
//
//  Mostly based on a Java version from 2003, itself based on a C version with
//  some code inherited from a Turing function.
//
//  The only significant difference between the Java version and this one is
//  that here, the name is immutable (and all derived values are prepared when
//  the Name object is created. If you want a new name, make a new Name.
//
//  Capitalization is somewhat different too, but I think there is no reasonable
//  set of capitalization rules that would work universally, even within the
//  subset of names used by English-speaking people. The goal is only to make
//  lists of names, such as class lists, not contain outstanding oddities.
//
//  As I am the only known user of the Name class, I don't think the differences
//  or peculiarities will cause trouble.
//  
//
//  Created by Jim Clarke on 2021-07-30.
//

import Foundation


extension Name : CustomStringConvertible {
    public var description: String {
//        if givenNames.isEmpty {
//            return familyName
//        } else {
//            return familyName + "  " + givenNames
//        }
        return name
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
        // Capitalize name if it does not already have both cases (because if it
        // does, presumably it was a deliberate choice).

        // Which cases are present in the name?
        var charsInName = CharacterSet()
        charsInName.insert(charactersIn: familyName)
        charsInName.insert(charactersIn: givenNames)
        let nameHasLowers = !charsInName
            .intersection(CharacterSet.lowercaseLetters).isEmpty
        let nameHasUppers = !charsInName
            .intersection(CharacterSet.uppercaseLetters).isEmpty
        let nameHasBothCases = nameHasLowers && nameHasUppers

        var cleanedFamily = familyName
        var cleanedGiven = givenNames
        if !nameHasBothCases {
            // Capitalize, because the user didn't do it.
            cleanedFamily = Name.capitalize(familyName)
            cleanedGiven = Name.capitalize(givenNames)
        }
        
        // Regardless of capitalization, fix the word separators so that they
        // are all single blanks.
        cleanedFamily = Name.standardize(cleanedFamily)
        cleanedGiven = Name.standardize(cleanedGiven)

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
    // This function is much less adventuresome than the Java version. It does
    // not try to consult the original to inspect the user's choice of
    // capitalization; in fact, it should probably not be used if the original
    // contains a mix of cases. Its first step is to lower-case the whole thing.
    // Then it makes a bunch of ordinary assumptions, with exceptions for a few
    // prefix mini-names such as "de" and "von".
    //
    // On the other hand, there is the hyphen. A hyphen, I think, separates two
    // parts of a name of equal importance -- names in themselves. There may be
    // multiple hyphens in a name, and each part should be capitalized
    // independently. That may be an odd choice: consider
    // "John-John Wilson-McNab", which would have the parts "John", "John
    // Wilson", and "McNab" -- not at all the real-world parsing -- but it
    // should be work correctly all the same.
    //
    // Wise as we may try to be, we'll still screw up, because names are
    // surprising even within a single culture. Prepare to apologize, and
    // suggest to e.e.cummings that "e.e. cummings (Yes!)" might keep us in
    // line.
    //
    // Non-whitespace characters are changed only in their case.
    //
    // As for the whitespace characters, the first step is to call
    // standardize(), so that we can assume all parts of the name are separated
    // by single blanks, and there are no leading or trailing blanks. This
    // means that if you want to use spacing information to identify the family
    // name, you have to do that before this function is called.
    
    public static func capitalize(_ name: String) -> String {
        // Put the name in lower case, and standardize it by removing any
        // leading or trailing blanks and making all the "word" separators into
        // single blanks. Then break it into separate words.
        //
        // Standardize() does make some non-blank word separators into blanks.
        // As of Nov/21, it only does that to SEPARATOR (",").
        
        let words = standardize(name.lowercased()).split(separator: " ")
        
        // Capitalize each word of the name and append it to fixedWords.
        var fixedWords = [String]()
        for i in 0 ..< words.count {
            let word = words[i]
            
            // Split this single word on a hyphen.
            var subwords = word.split(separator: "-",
                                      omittingEmptySubsequences: false)
            // Someone is going to try putting in leading hyphens, or multiple
            // hyphens. We try to preserve that possible silliness by hanging on
            // to empty subsequences.
            
            // After this loop, we'll recombine the capitalized subwords into
            // a fixed word, with hyphens between them.
            for subi in 0 ..< subwords.count {
                var subword = subwords[subi]
                // What if someone tries adjacent hyphens, or a leading hyphen?
                if subword.isEmpty {
                    continue
                }
                
                // Capitalize the first character, usually.
                var capitalizeFirstChar = true
                
                // .. but not if the word is a prefix indicating noble descent.
                let noblePrefixes: [Substring] = ["de", "di", "van", "von"]
                if noblePrefixes.contains(word)
                    // Ignore this rule on the last word in the name, so as to
                    // avoid (e.g.) leaving a truncated "Dennis" uncapitalized.
                    && (i < words.count - 1 || subi < subwords.count - 1)
                {
                    capitalizeFirstChar = false
                }
                
                // Do it, serf!
                if capitalizeFirstChar {
                    let firstChar = subword.removeFirst()
                    subword.insert(contentsOf: firstChar.uppercased(),
                                at: subword.startIndex)
                }
                
                // We are willing to capitalize one other internal character.
                // Any more and the code needs rethinking. Or perhaps the user
                // could be more careful with capitalization?
                var internalCapIndex = -1
                
                // Look for prefixes (internal to the subword) that might
                // require internal capitalization. For some of these,
                // capitalization might be optional, but the user didn't bother
                // being particular, so we can't be.
  
                if subword.starts(with: "Mc") {
                    internalCapIndex = 2
                // } else if subword.starts(with: "Mac") {
                    // This case is deleted because of Macdonald and Macintosh,
                    // and also because of (e.g.) Italian names starting with
                    // Mac.
                //     internalCapIndex = 3
                } else if subword.starts(with: "O'") {
                    internalCapIndex = 2
                // } else if subword.starts(with: "Fitz") {
                    // This case is deleted because my guess is that more Fitzes
                    // are followed by a lower-case than an upper-case letter.
                //     internalCapIndex = 4
                }
                
                // Make the internal adjustment.
                if internalCapIndex > 0 && internalCapIndex < subword.count {
                    let location = subword.index(subword.startIndex,
                                                 offsetBy: internalCapIndex)
                    let nthChar = subword.remove(at: location)
                    subword.insert(contentsOf: nthChar.uppercased(),
                    at: location)
                }
                
                subwords[subi] = subword
            }
            
            // Recombine the subwords into a hyphenated word.            
            var fixedword = ""
            for subword in subwords {
                fixedword += subword + "-"
            }
            if fixedword.count > 0 {
                // If word is empty, subwords may have zero elements.
                fixedword.removeLast()
            }

            fixedWords.append(fixedword)
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


