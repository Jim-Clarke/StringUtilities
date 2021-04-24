# StringUtilities

Some simple string operations I've needed more than once

### In the file StringUtilities.swift:
- applyRegex(regex: target:) -> [[String]]
- getQuotedString(source: start: quote:) -> (String?, String.Index?)
- unquotedIndexOf(source: char: quote:) -> String.Index?
- getBracketedString(source: start: leftBracket: rightBracket: quote:) -> (String?, String.Index?)
- nChars(n: char:) -> String
- nBlanks(n) -> String
- leftPadded(source: desiredCount:) -> String
- rightPadded(source: desiredCount:) -> String
- skipWhitespace(source: start:) -> String.Index?
- trimWhitespace(source:) -> String


### In the file OptionScanner.swift:
- A class OptionScanner and associated support, to ease reading command-line options
