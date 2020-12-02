// Some functions (etc?) here are based in part on methods and constructors in
// these Java classes:
//      BracketedStringFormat
//      WhiteSpaceFormat
//      QuotedStringFormat
//      OptionScanner
//      OptionUser
//
// -- Jim Clarke, Nov 2020

// We might need a trimLeft, or trimRight, or getFirstWord. But I don't know
// yet.

import Foundation

let DEFAULT_LEFT_BRACKET = Character("(")
let DEFAULT_RIGHT_BRACKET = Character(")")
let DEFAULT_QUOTE_CHAR = Character("\"")
let ESCAPE_CHAR = Character("\\")


// Given regex, a regular expression, and target, possibly containing
// matches for regex, return all the matches, including for each all the
// captured substrings.
//
// Returns an empty array of arrays of String if no match is found --
// that is, [] of type [[String]].

func applyRegex(regex: String, target: String) -> [[String]] {
    // Reference: https://nshipster.com/swift-regular-expressions/
    
    let nsregex = try! NSRegularExpression(pattern: regex, options: [])

    let nsrange = NSRange(target.startIndex ..< target.endIndex, in: target)
    var matches = [[String]]()
    nsregex.enumerateMatches(in: target,
                           options: [],
                           range: nsrange
                          ) { (match, _, _) in
        guard let match = match else { return }
        
        var matchingStrings = [String]()
        for i in 0 ..< match.numberOfRanges {
            let captureRange = Range(match.range(at: i), in: target)
            let matchingString = String(target[captureRange!])
            matchingStrings.append(matchingString)
        }
        matches.append(matchingStrings)
    }
    
    return matches
}


// Consider the "source" string to consist of these parts:
//      <ws><quote><resultstr><quote><tail>
// where ws is optional whitespace
//      quote is the quote character
//      resultstr is the first value to be returned
//      tail is the possibly empty remainder of source
// If source can be matched to this pattern, then the return values are
//      (resultstr, pos)
// where pos is the string index of the first character in the tail, or
// source.endIndex if the tail is empty.
//
// If start is non-nil and past source.startIndex, then instead of source
// itself, the function works with the part of source starting at start. The
// "pos" returned is relative to the beginning of source, so source[pos] is
// always the first character not used, or the end of source.
//
// A call with start == nil is equivalent to a call with source ==
// source.startIndex.
//
// In case of failure, the values returned are
//      (nil, nil).
// Reasons for failure include:
// - source == nil
// - start past end of source
// - first non-whitespace character is not quote
// - no non-whitespace character found
// - terminating quote not found
//
// [The previous (Java) implementation returned (nil, pos) in case of failure,
// where pos was the position of the first non-whitespace character. This seems
// of little use, and was done partly because pos was a var parameter and not an
// actual return value, and possibly also to match the Java specifications of
// other format objects.]
//
// A resultstr may include quoted substrings, delimited by the quote character.
// Within a quoted substring, brackets are ignored -- that is, not considered
// special. Also within a quoted substring, escaped quote characters are not
// special -- that is, do not terminate the quoting. The escape character is the
// backslash, '\'. Outside a quoted substring, escape characters are not
// special.
//
// If quote is whitespace or the same as ESCAPE_CHAR, the results could be
// interesting.
//
// Essentially the same as QuotedStringFormat.parse(String, ParsePosition) in
// the Java version.

func getQuotedString(
        source: String?,
        start: String.Index? = nil,
        quote: Character = DEFAULT_QUOTE_CHAR
    ) -> (String?, String.Index?)
{
    guard let source = source else {
        return (nil, nil)
    }
    
    // Start search from the beginning of source if we're not told otherwise.
    var pos = start ?? source.startIndex
    if pos >= source.endIndex {
        return (nil, nil)
    }
    
    // We need at least two characters, so that we can have matching brackets.
    // This test probably wastes a little time, but it simplifies thinking about
    // the code.
    if source.count < 2 {
        return (nil, nil)
    }
    
    // Skip leading whitespace.
    while pos < source.index(before: source.endIndex)
                    // We need space for TWO quotes.
            && CharacterSet.whitespaces
                    .contains(Unicode.Scalar(String(source[pos]))!) {
        pos = source.index(after: pos)
    }
    if (pos >= source.endIndex)
            || (source[pos] != quote) {
        return (nil, nil)
        // We could return (nil, pos) to tell the caller how much whitespace
        // we read. But we don't.
    }
    
    // We have the beginning of the quoted string. Now find the end.
    let left = source.index(after: pos)
    var right = left // not "after left": right could already be the end
    while right < source.endIndex && source[right] != quote {
        if source[right] == ESCAPE_CHAR {
            right = source.index(after: right)
            if right == source.endIndex {
                // Really? An escape within a quoted string is the last
                // character in source?
                return (nil, nil)
            }
        }
        right = source.index(after: right)
    }
    if right >= source.endIndex {
        return (nil, nil)
    }

    // Now left is the position of the first character after the left quote, and
    // right is the position of the terminating right quote.

    // Construct the string to be returned.
    var result = source[left ..< right]
    
    // Remove the significant escapes from result. That is, for pairs \c (where
    // c is an escape or a quote), replace the pair by just c, unescaped.
    var toBeDeleted = [String.Index]()
    for i in result.indices {
        if result[i] == ESCAPE_CHAR {
            let nextIndex = result.index(after: i)
            if nextIndex < result.endIndex
                && (result[nextIndex] == ESCAPE_CHAR || result[nextIndex] == quote) {
                toBeDeleted.insert(i, at: 0) // at 0 to get reversed order
            }
        }
    }
    // We listed the deletion indices backwards. Now we remove them forwards.
    for i in toBeDeleted {
        result.remove(at: i)
    }
    
    // We're done.
    
    return (String(result), source.index(after: right))
}


// Return the index within source of the first unquoted instance of char, or nil
// if an unquoted ch is not found in source.
//
// An "unquoted instance" is an instance that is not within a substring quoted
// in the style of getQuotedString(). Within quoted substrings, the escape
// character affects the treatment of the quote character and of other escape
// characters, but the character being searched for is disregarded within quoted
// substrings regardless of the escape character. Outside quoted substrings, the
// escape character is not special.
//
// If char is the quote character, the first quote character in source will be
// accepted. If char is the escape character, the first one that is not in a
// quoted substring will be accepted.
//
// If source is nil or if char is not found, nil is returned.
//
// At present there seems no need for a parameter indicating a starting position
// in source.
//
// Essentially the same as QuotedStringFormat.unquotedIndexOf(String, char) in
// the Java version.

func unquotedIndexOf(source: String?,
                     char ch: Character,
                     quote: Character = DEFAULT_QUOTE_CHAR
    ) -> String.Index?
{
    let quote = DEFAULT_QUOTE_CHAR

    // Did they give us a string?
    guard let source = source else {
        return nil
    }

    // Search from the start of source.
    var pos = source.startIndex
    if pos >= source.endIndex {
        return nil
    }
    
    while pos < source.endIndex {
        let c = source[pos]
        if c == ch {
            return pos
        }
        
        else if c == quote { // Skip quoted string.
            var newPos: String.Index?
            (_, newPos) = getQuotedString(
                source: source, start: pos, quote: quote
            )
            if newPos == nil {
                return nil
            } else {
                // Back up one: getQuotedString leaves the string index pointed
                // at the character after the closing quote. At the end of this
                // loop we advance "right" by one, so if we didn't back up, we
                // would miss that next character.
                pos = source.index(before: newPos!)
            }
            
            
            // Here's the previous "do-it-yourself" version of quoted-string
            // skipping that was replaced by calling getQuotedString above. It
            // was hard enough to "proved" the code was right that doing it
            // twice ... well, thrice ... seemed less than ideal.
            // pos = source.index(after: pos)
            //
            // while pos < source.endIndex && source[pos] != quote {
            //     if source[pos] == ESCAPE_CHAR {
            //         pos = source.index(after: pos)
            //         if pos == source.endIndex {
            //             // An escape within a quoted string is the last
            //             // character in source!
            //             return nil
            //         }
            //     }
            //     pos = source.index(after: pos)
            // }

            // Is the last character in source the final quote, or part
            // of the quoted string?
            if pos >= source.endIndex {
                return nil
            }
        } // end of skipping quoted string
        
        pos = source.index(after: pos)
    }
    
    return nil // We never did find ch.
}


// Consider the "source" string to consist of these parts:
//      <ws><lbr><resultstr><rbr><tail>
// where ws is optional whitespace
//      lbr is the leftBracket character
//      resultstr is the first value to be returned
//      rbr is the rightBracket character
//      tail is the possibly empty remainder of source
// If source can be matched to this pattern, then the return values are
//      (resultstr, pos)
// where pos is the string index of the first character in the tail, or
// source.endIndex if the tail is empty.
//
// If start is non-nil and past source.startIndex, then instead of source
// itself, the function works with the part of source starting at start. The
// "pos" returned is relative to the beginning of source, so source[pos] is
// always the first character not used, or the end of source.
//
// A call with start == nil is equivalent to a call with source ==
// source.startIndex.
//
// In case of failure, the values returned are
//      (nil, nil).
// Reasons for failure include:
// - source == nil
// - start past end of source
// - first non-whitespace character is not leftBracket
// - no non-whitespace character found
// - balancing rightBracket not found
//
// [The previous (Java) implementation returned (nil, pos) in case of failure,
// where pos was the position of the first non-whitespace character. This seems
// of little use, and was done partly because pos was a var parameter and not an
// actual return value, and possibly also to match the Java specifications of
// other format objects.]
//
// A resultstr may include quoted substrings, delimited by the quote character.
// Within a quoted substring, brackets are ignored -- that is, not considered
// special. Also within a quoted substring, escaped quote characters are not
// special -- that is, do not terminate the quoting. The escape character is the
// backslash, '\'. Outside a quoted substring, escape characters are not
// special.
//
// If one or more of the set {leftBracket, rightBracket, quote} are the same or
// whitespace, the results could be interesting -- and implementation-dependent.
//
// Essentially the same as BracketedStringFormat.parse(String, ParsePosition) in
// the Java version.

func getBracketedString(
        source: String?,
        start: String.Index? = nil,
        leftBracket: Character = DEFAULT_LEFT_BRACKET,
        rightBracket: Character = DEFAULT_RIGHT_BRACKET,
        quote: Character = DEFAULT_QUOTE_CHAR
    ) -> (String?, String.Index?)
{
    guard let source = source else {
        return (nil, nil)
    }
    
    // Start search from the beginning of source if we're not told otherwise.
    var pos = start ?? source.startIndex
    if pos >= source.endIndex {
        return (nil, nil)
    }
    
    // We need at least two characters, so that we can have matching brackets.
    // This test probably wastes a little time, but it simplifies thinking about
    // the code.
    if source.count < 2 {
        return (nil, nil)
    }
    
    // Skip leading whitespace.
    while pos < source.index(before: source.endIndex)
                    // We need space for TWO brackets.
            && CharacterSet.whitespaces
                    .contains(Unicode.Scalar(String(source[pos]))!) {
        pos = source.index(after: pos)
    }
    if (pos >= source.endIndex)
            || (source[pos] != leftBracket) {
        return (nil, nil)
        // We could return (nil, pos) to tell the caller how much whitespace
        // we read. But we don't.
    }
    
    // We have the beginning of the bracketed string. Now find the end.
    let left = source.index(after: pos)
    var right = left // not "after left": right could already be the end
    var bracketCount = 1
    while right < source.endIndex && bracketCount > 0 {
        let ch = source[right]
        if ch == leftBracket {
            bracketCount += 1
        }
        else if ch == rightBracket {
            bracketCount -= 1
        }
        else if ch == quote { // Skip quoted string.
            var newPos: String.Index?
            (_, newPos) = getQuotedString(
                source: source, start: right, quote: quote
            )
            if newPos == nil {
                return (nil, nil)
            } else {
                // Back up one: getQuotedString leaves the string index pointed
                // at the character after the closing quote. At the end of this
                // loop we advance "right" by one, so if we didn't back up, we
                // would miss that next character.
                right = source.index(before: newPos!)
            }

            // Here's the previous "do-it-yourself" version of quoted-string
            // skipping that was replaced by calling getQuotedString above. It
            // was hard enough to "proved" the code was right that doing it
            // twice ... well, thrice ... seemed less than ideal.
            //
            // pos = source.index(after: pos)
            // right = source.index(after: right)
            // while right < source.endIndex && source[right] != quote {
            //     if source[right] == ESCAPE_CHAR {
            //         right = source.index(after: right)
            //         if right == source.endIndex {
            //             // Really? An escape within a quoted string is the last
            //             // character in source?
            //             return (nil, nil)
            //         }
            //     }
            //     right = source.index(after: right)
            // }
            
            if right >= source.endIndex {
                return (nil, nil)
            }
        }
        
        right = source.index(after: right)
    }
    if bracketCount > 0 {
        return (nil, nil)
    }

    // Now left is the position of the first character after the left bracket,
    // and right is one past the terminating right bracket. We're done.
    return (String(source[left ..< source.index(before: right)]), right)
}


// Return a string consisting of n copies of char. If n < 0, it is treated
// as 0.

public func nChars(_ n: Int, char: Character = " ") -> String
{
    let wanted = n >= 0 ? n : 0
    var result = ""
    while result.count < wanted {
        result.append(char)
    }
    return result
}

// Return a string of n blanks. If n < 0, it is treated as 0. This function is
// needed only to make user code more readable.
//
// Essentially the same as WhiteSpaceFormat.formatHelper(int) in the Java
// version.

func nBlanks(_ n: Int) -> String
{
    return nChars(n)
}

// Return "source" padded on the left with enough blanks to make its length
// at least desiredCount. If source is already longer than that, it is not
// shortened.
//
// Essentially the same as WhiteSpaceFormat.leftPad(String, int) in the Java
// version.

func leftPadded(_ source: String, desiredCount: Int) -> String {
    let neededExtras = desiredCount - source.count
    return nBlanks(neededExtras) + source
}

// Return "source" padded on the right with enough blanks to make its length
// at least desiredCount. If source is already longer than that, it is not
// shortened.
//
// Essentially the same as WhiteSpaceFormat.rightPad(String, int) in the Java
// version.

func rightPadded(_ source: String, desiredCount: Int) -> String {
    let neededExtras = desiredCount - source.count
    return source + nBlanks(neededExtras)
}

// Skip whitespace characters in the string "source", starting at index "start",
// or the beginning of source if start is nil, and returning the position of the
// first non-white character or the end of the string, whichever is first.
//
// If start is greater than (but not equal to) source.endIndex, nil is returned.
// If start is equal to source.endIndex, source.endIndex is returned.
//
// Essentially the same as WhiteSpaceFormat.parse(String, ParsePosition) in the
// Java version.

func skipWhitespace(_ source: String, start: String.Index? = nil) -> String.Index?
{
    // Start at the beginning of source if we're not told otherwise.
    var pos = start ?? source.startIndex
    if pos > source.endIndex {
        return nil
    }
    
    // Skip.
    while pos < source.endIndex
            && CharacterSet.whitespaces
                    .contains(Unicode.Scalar(String(source[pos]))!) {
        pos = source.index(after: pos)
    }
    
    return pos
}

// Return a string that is the same as source except with leading and trailing
// whitespace removed.

func trimWhitespace(_ source: String) -> String
{
    // Trim the beginning: set pos to the position of the first nonblank, or
    // the string's endIndex if it is entirely whitespace.

    var pos = skipWhitespace(source)
    
    guard pos != nil else {
        // pos == nil cannot occur because skipWhitespace, called with a nil
        // "start", cannot return nil.
        return ""
    }

    if pos == source.endIndex {
        // "source" is entirely whitespace.
        return ""
    }
    
    let rightPart = source[pos! ..< source.endIndex]

    // Trim the end: move pos to the position just after the last nonblank.

    pos = rightPart.endIndex
    
    while pos! > rightPart.startIndex
            && CharacterSet.whitespaces
            .contains(Unicode.Scalar(String(
                                        rightPart[rightPart.index(before:pos!)]))!
            ) {
        pos = rightPart.index(before: pos!)
    }

    return String(rightPart[rightPart.startIndex ..< pos!])
}

