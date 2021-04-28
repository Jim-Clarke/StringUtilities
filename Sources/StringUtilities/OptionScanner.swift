//
//  OptionScanner.swift
//
//  Created by Jim Clarke on 2021-02-03.
//

import Foundation

// This class helps you extract the options set in a Unix-style command line.
// It should remind you of C's getopt(), but it doesn't do exactly the same
// things.

// How to use it -- a brief summary
//
// 1. Create a "scanner" -- an instance of the OptionScanner class:
//      let scanner = OptionScanner("axb")
//    Here "axb" is the OPTION STRING. It tells scanner what options to accept.
//    This option string specifies the options -a, -b and -x.
//
//    Here's a maximally complicated option string:
//      "+!b:<filename>"
//    The parts are:
//      + can be called with +a instead of -a. Rarely used, I bet.
//      ! must be called with -a, +a or both. It's a nonoptional option.
//      b the OPTION CHARACTER for this option. The only compulsory parts of an
//        option string are the option characters -- one per option.
//      : it takes an OPTION ARGUMENT that may be either in the following
//        command-line argument ("-b myfile") or in the rest of the same one
//        ("-bmyfile").
//      <filename> when scanner constructs a usage string, it will use
//        "filename" to describe the option argument. You can leave this out and
//        just use "+!b:" for the option string; scanner will use a default
//        name.
//    The parts of the option must appear in the order shown, but all the parts
//    are independent of each other (except that "<...>" can only appear if
//    there's a ":").
//
// 2. Call scanner.usageString() to build a usage message:
//      let usageMessage =
//          "Usage: <programName> " + scanner.usageString() + restOfArgs
//    You can omit this step if your users never need help.
//
// 3. Call scanner.getOpts(args) to set the options from step 1 from the
//    command-line arguments. For example, if the option string is "axb" and
//    args is
//      ["progname", "-x", "-a", "nonoptionalargument"]
//    then the arguments a and x are set. Usually the sensible value for args
//    is simply what CommandLine.arguments gives you -- which in Swift does
//    include the program name, argument 0.
//
//    GetOpts() reads the arguments until a non-option argument is encountered:
//    either one that doesn't start with "-" or the special argument "--". Its
//    return value is an Int giving the index of the first unused argument.
//    Start there to read whatever (non-option) arguments are left: file names,
//    etc. (Non-option arguments must come after all the arguments that specify
//    options.)
//
//    More than one option can be set in a command-line argument ("-ab"), but
//    not if the option takes its own argument:
//      bad: "-abmyfile" bad,  good: "-a" "-b42" (or "-a" "-b" "42")
//
// 4. Act on the options in the list scanner.allOptions, which is of type
//    [OptionScanner.Option]. That list includes both set and unset options, so
//    here's a simple outline for a processing loop:
//
//      for o in scanner.allOptions where o.isSet {
//          switch o.optionChar {
//          case "a": // do what -a tells you to do
//          case "b": // ...
//          case "x": // ...
//          default:
//              // You won't reach here, because if the arguments refer to an
//              // unrecognized option, then getOpts() has already thrown an
//              // OptionError.failedGet. But Swift wants a default.
//              print(usageMessage)
//              exit(1)
//          }
//      }
//
//    The OptionScanner.Option class has attributes to tell you how the option
//    was set, what the option argument was, etc.


// That should cover the most common ways of using this facility. Here are more
// details, and then an elaborate special case involving submodules.


// The public facilities provided in this file
//
// OptionError: the Errors thrown when things go wrong here:
//  OptionError.failedParse: trouble with an option string.
//  OptionError.failedGet: trouble with reading options in getOpts().
//
// OptionUser: a protocol for subordinate option-using modules (Needed only if
//      you're working with submodules.)
//
// OptionScanner: the major class defined here. The rest of this list gives its
//      public members.
//
// Option: a class for objects that describe individual command-line options
//      Its public members are listed in its code before other members.
//
// init(optionString: ...) throws  (The "..." parameters have defaults.)
//
// addUser(newUser:OptionUser, optionString:String) throws
//      Add a submodule user of the scanner.
// 
// usageString(...) -> a String that can be used in a "Usage:" message.
//
// getOpts(args:[String]) throws -> Int


// Working with submodules that want to read the command line
//
// Suppose your program Main depends on a module Sub1 that sorts its data. Sub1
// has a standard set of options that specify increasing or decreasing order,
// which subfield to sort on, etc. Another module Sub2 lets you choose a subset
// of your data to work with.
//
// You want to use Sub1's and Sub2's command-line options, but you do not want
// to have to build them into Main.
//
// Here's how to modify the steps described above.
//
// 0. Write Sub1 and Sub2 so that they implement the OptionUser protocol.
//
// 1. (a) [After step 1] The Subs  add themselves as users to scanner:
//    In Sub1: scanner.addUser(self, "pq")
//    In Sub2: scanner.addUser(self, "rs")
//
//    The option strings for Main, Sub1, Sub2 can't have overlapping option
//    characters.
//
// 2. (a) In Main, call scanner.usageString() as before. That sets up the Subs'
//    usage strings and notifies the Subs by calling notifyUsageStringReady for
//    each of them.
//
//    UsageString() returns a usage string to Main. By default this return value
//    includes just the parts that concern Main's options, and Main can fetch
//    the Subs' option strings from them so as to put together a combined usage
//    message.
//
//    Or you can get the combined usage string, covering both Main and the Subs
//    -- by setting usageString()'s returnSpecificCreatorOptions parameter to
//    false. 
//
// 3. As in the simple case, Main calls scanner.getOpts() -- but then things
//    change.
//
//    (a) Something like usageString() in 2(a), getOpts() sets the "options"
//    members of the Subs, and then calls notifyOptionsReady for each of them.
//    That function is a sensible place for them to act on the values of their
//    options (step 4).
//
//    (b) Main can continue to work with the list scanner.allOptions, but
//    it does include all options, including the ones for the Subs. Instead, you
//    can use scanner.creatorOptions, with just the options belonging to Main.
//    Both lists are automatically filled by a single getOpts() call.
//
// 4. Both Main and the Subs process their options as in the simple case.


// Some pedantic details

// Summary: here are the parts of an option string entry for an option "a":
//
// +        Alternative option indicator is allowed.
// !        Option must be set.
// a        Option character
// :        Option takes an argument (or two if + is set).
// <argument name>                  name of the regular argument
// <alternative argument name>      name of the alternative argument
//
// The parts must be in the order shown.

// An option accepting "+" still accepts "-". If an option accepts "+", it can
// be set with neither, either or both of "-" and "+". You can find out what
// happened, and impose further requirements, when you deal with the scanned
// options provided by getOpts().

// Both "-" and "+" can be changed. Those are default values of parameters to
// OptionScanner's init() -- optionIndicator and alternativeOptionIndicator,
// respectively. Changes can affect not just the command line but also the
// option string you give to init(). If the alternative option indicator is
// reset, say from "+" to "%", then the option string would be "a%bc:%d" instead
// of "a+bc:+d".


// Notes to myself
//
// Differences between this package and the Java class I wrote in 2003:
//
// - The scanner deposits both usage strings and option lists directly in
//   variables belonging to the subusers, instead of responding to queries.
//
// - The parameter "args" for getOpts() -- the list of command-line arguments
//   now includes the name under which the program was called -- the usual
//   zeroth element in a Unix command line. That is, I used to do what Java made
//   easy, and now I do what Swift makes easy.
//
// - scan() is now called getOpts().
//
// - I don't remember why the Java version required an option taking an
//   argument to be given in its own separate command-line argument. I
//   considered removing this rule, but am not bothered enough to make the
//   change.
//
// - An option that does not allow the "+" indicator now returns false when
//   queried on isSetWithAlt, instead of throwing an exception.
//
// - An option taking arguments and allowing the "+" indicator now has distinct
//   names for the "-" and "+" arguments.
//
// - If non-standard option indicators (that is, not the minus and plus that are
//   standard), they are more faithfully reflected in error messages now.
//
//
// Ways I know of in which OptionScanner is not like C's getopt() as of ~2000:
// - the "+" character does not have the same meaning as in getopt()
// - the "!" usage does not correspond to anything in getopt()
// - the non-alphanumeric character "?" is accepted as an option, and presumably
//   non-ASCII alphanumerics are accepted
// - it is not possible for an option to have an optional argument: either it
//   takes an argument, or it doesn't
// - the capability of naming option arguments is not part of getopt().
// - the options are always assumed to be at the beginning of the array of
//   arguments.
// 
//        -- J. Clarke, April 2003 and April 2021


// An error thrown by functions here should always either be an OptionError or
// be wrapped in the "msg" of an OptionError.

public enum OptionError: Error {
    case failedParse(_ msg: String)
    case failedGet(_ msg: String)
}

public protocol OptionUser {
    // An OptionUser has attributes and functions allowing it to be set and
    // called by the OptionScanner that belongs to the main program.
    //
    // Programs in which all the command-line options are defined by a single
    // main program do not need any OptionUsers.
    
    // A list of the Options belonging to this OptionUser. It is built by the
    // OptionScanner after all the options have been created, but it is not
    // ready for use until the options have been set by getOpts(). At that
    // point, the scanner calls this OptionUser's notifyOptionsReady().
    var options: [OptionScanner.Option] { get set }
    
    // A partial Usage message containing just the usage information for this
    // OptionUser's options. This string is constructed by OptionScanner's
    // usageString(), which then calls notifyUsageStringReady().
    var usageString: String { get set }

    // Called by the OptionScanner once it has finished running usageString()
    // on the various lists of options. At this point, the OptionUser can
    // construct its Usage message incorporating usageString.
    func notifyUsageStringReady()
    
    // Called by the OptionScanner once it has finished running getOpts() on the
    // command-line arguments. At this point, the OptionUser can read its
    // options and act on the ones that have been set.
    func notifyOptionsReady()
}

public class OptionScanner {
    
    // Public attributes of OptionScanner:
    
    // Lists constructed from "options" and "users" after they are complete
    
    // Briefly, allOptions is everything, and creatorOptions is options
    // belonging to the original caller but not to any OptionUser.
    //
    // Options belonging to an OptionUser are stored in that OptionUser object.
    
    public var allOptions = [Option]() // derived from the values in options
    // after all options have been read: a combination of creatorOptions and
    // all the OptionUsers' options.
    public var creatorOptions = [Option]() // the options for the "creator" user
        // The creator could have been treated as a nil OptionUser, but it   
        // seemed better to have a separate, named list.
        //
        // Still, an Option owned by the creator does have owner == nil.
    
    // Public functions of OptionScanner needed for the simple usage case:
    //
    // - the class Option.
    // - init(_ optionString:, <two defaulted parameters>)
    // - usageString(<one defaulted parameter>) -> String
    // - getOpts(_ args:) -> Int

    // Additional OptionScanner member needed for the multi-module case
    // - addUser(_ newUser:, _ optionString:)
    
    
    // A note to the reader: Unix command-line options are set by an argument
    // starting with "-"; for example, "-a" sets an option corresponding to "a".
    // Rarely, an argument may start with "+" instead; for example, see sort's
    // ("obsolete") +pos argument.
    //
    // Here, in private, because my brain works better that way, we refer to
    // those characters as "plus" and "minus". Where a name may be seen by a
    // caller -- e.g., any public class member -- or by a user -- e.g., in
    // an error message -- we replace "plus" with "alt".
    //
    // In OptionScanner's init(), a parameter is called "optionIndicator". By
    // default its value is "-" and it is called minusChar internally. If you're
    // using a system descended from MS-DOS, you'll want to set it to "/", I
    // guess -- but I don't even know what value you'd use for
    // alternativeOptionIndicator, a.k.a. plusChar.

    public class Option {
        // attributes that users of OptionScanner need to be able to refer to
        // when the OptionScanner returns Options to them
        public let optionChar: Character // identifies this Option
        public internal(set) var isSet = false
        public internal(set) var isSetWithAlt = false
        public internal(set) var arg: String?
        public internal(set) var argForAlt: String?

        var owner: OptionUser? // nil for creator of this OptionScanner
        var isRequired = false

        let plusChar: Character // passed in at creation by the OptionScanner
            // Currently used only in error messages (and should stay that way!
            // -- because it's really not an Option attribute)
        var allowsPlus = false
        func setWithPlus() throws {
            if !allowsPlus {
                throw OptionError.failedGet("""
'\(plusChar)' set on non-\(plusChar) option '\(optionChar)'
""")
            } else {
                isSetWithAlt = true
            }
        }

        var takesArg = false
        var argDescription: String?
        
        func setArg(arg: String) throws {
            if !takesArg {
                throw OptionError.failedGet(
                    "option argument set on non-arg option '\(optionChar)'")
            } else {
                self.arg = arg
            }
        }
        
        func setArgDescription(description: String) throws {
            if !takesArg {
                // I'm pretty sure it's impossible to provoke this error message
                // as the class is currently written, because the leading '<'
                // enclosing the description is an invalid character if no
                // description is expected, so parseOptions() will fail first.
                throw OptionError.failedParse("""
option argument description set on non-arg option '\(optionChar)'
""")
            } else {
                self.argDescription = description
            }
        }
        
        // In this implementation, takesPlusArg == (takesArg && allowsPlus)
        // (See parseOptions().) This is unlikely to change, but we might as
        // well keep takesPlusArg to preserve the illusion of freedom.
        var takesPlusArg = false
        var argForAltDescription: String?
        
        func setPlusArg(arg: String) throws {
            if !takesPlusArg {
                throw OptionError.failedGet("""
\(plusChar) option argument set on non-\(plusChar)-arg option '\(optionChar)'
""")
            } else {
                self.argForAlt = arg
            }
        }
        
        func setPlusArgDescription(description: String) throws {
            if !takesPlusArg {
                // I'm pretty sure it's impossible to provoke this error message
                // as the class is currently written. See comment in
                // setArgDescription().
                throw OptionError.failedParse("""
\(plusChar) option argument description set\
 on non-\(plusChar)-arg option '\(optionChar)'
""")
            } else {
                self.argForAltDescription = description
            }
        }


        init(_ optionChar: Character,
             alternativeOptionIndicator plusChar: Character
             )
        {
            self.optionChar = optionChar
            self.plusChar = plusChar
        }

    } // end of class Option


    // Non-alphanumerics allowed as option characters
    static let extraOptionCharacters = CharacterSet(charactersIn: "?#")
    static let optionCharacters =
        CharacterSet.alphanumerics.union(extraOptionCharacters)
    
    // Characters with meaning in the option string
    static let isRequiredOptionChar: Character = "!"
    static let takesArgChar: Character = ":"
    static let optArgNameLeftBracket: Character = "<"
    static let optArgNameRightBracket: Character = ">"
    
    // Talking to users, we call these two "optionIndicator" and
    // "alternativeOptionIndicator". Internally, we're Unix people.
    let minusChar: Character
    let plusChar: Character
    
    static let optionListEnder = "--"
    
    // The optionString is fixed when the OptionScanner is initialized.
    // It contains the option characters belong strictly to the "creator" user,
    // and not to the OptionUsers, if any.
    let optionString: String

    // Each option is associated with its unique option character. As they are
    // read and constructed (in parseOptions()), we put them in this dictionary.
    //
    // This dictionary is not public. The public options are in allOptions and
    // creatorOptions.
    var options = [Character: Option]()
    
    // Self-explanatory, I hope. Collected by addUser().
    var users = [OptionUser]()
    
    var stillAcceptingNewUsers = true // set to false by buildOptionLists()
    // the first time it is called (by usageString() or getOpts()), and checked
    // by addUser() to detect late attempts to add, and by buildOptionLists() to
    // avoid rebuilding the same lists.


    // Initialize this OptionScanner.
    //
    // Parameters:
    //  optionString: the option characters for the "creator" -- the module or
    //      program that initializes this OptionScanner
    //
    //  optionIndicator: usually, "-". Perhaps "/" if prefer MS-DOS to Unix.
    //
    //  alternativeOptionIndicator: usually "+", but rarely used. Your choice!
    //
    // Throws: OptionError.failedParse if there's a problem with optionString.
    
    public init(_ optionString: String,
                optionIndicator minusChar: Character = "-",
                alternativeOptionIndicator plusChar: Character = "+"
            ) throws
    {
        self.optionString = optionString
        self.minusChar = minusChar
        self.plusChar = plusChar
        try parseOptions(optionString, owner: nil)
        // Just pass along any error; it should be an OptionError.failedParse.
    }


    // Add an OptionUser as a new user for this OptionScanner.
    //
    // Parameters:
    //  newUser: the new OptionUser. Very likely, this function is called by the
    //      new OptionUser itself, with newUser set to self.
    //
    //  optionString: the option characters for the new user.
    //
    // Throws: OptionError.failedParse if there's a problem with optionString
    //  or between this optionString and previously parsed optionString.
    
    public func addUser(_ newUser: OptionUser, _ optionString: String) throws {
        users.append(newUser)
        if !stillAcceptingNewUsers {
            throw OptionError.failedParse("""
too-late attempt to add optionUser with option string \"\(optionString)\"
""")
        }
        try parseOptions(optionString, owner: newUser)
        // Any error should be an OptionError.failedParse.
    }
    
    // Extract options from optionString and add them to this OptionScanner's
    // collection of options.
    //
    // This method is not called "addOptions" as it was in the Java version,
    // because most of its work is parsing, so the new name should help the
    // reader. However, the extracted options are in fact added to those already
    // known. This method may be called more than once, if the OptionScanner has
    // more than one OptionUser; in that case, this method really is *adding*
    // options to the existing collection.
    //
    // Parameters:
    //  optionString: the option string to be parsed
    //  owner: the OptionUser who will be the owner of the created Options
    //      -- nil if the owner is the creator of this OptionScanner
    //
    // Throws: OptionError.failedParse if parsing fails for any reason.
    
    func parseOptions(_ optionString: String, owner: OptionUser?) throws {
        var pos = optionString.startIndex
        while pos < optionString.endIndex {
            var optc = optionString[pos]
            var allowsPlus = false
            var isRequired = false
            
            // Does the current option allow '+' in its command-line argument?
            if optc == plusChar {
                pos = optionString.index(after: pos)
                if pos >= optionString.endIndex {
                    throw OptionError.failedParse(
                        "option string \"\(optionString)\" ended prematurely")
                }
                allowsPlus = true
                optc = optionString[pos]
            }
            
            // Is the current option required to be selected?
            if optc == OptionScanner.isRequiredOptionChar {
                pos = optionString.index(after: pos)
                if pos >= optionString.endIndex {
                    throw OptionError.failedParse(
                        "option string \"\(optionString)\" ended prematurely")
                }
                isRequired = true
                optc = optionString[pos]
            }

            // Check that optc is a valid option character.
            if !OptionScanner.optionCharacters.contains(
                    Unicode.Scalar(String(optc))!) {
                throw OptionError.failedParse(
                    "bad character '\(optc)' in option string \"\(optionString)\"")
            }

            // Create the option object.
            let option = Option(optc, alternativeOptionIndicator: plusChar)
            
            // Tell it who owns it. Remember, it could be nil.
            option.owner = owner
            
            // Add it to the options dictionary.
            if options[optc] != nil {
                throw OptionError.failedParse("""
duplicate option character '\(optc)' in option string \"\(optionString)\"
""")
            } else {
                options[optc] = option
            }
            
            option.allowsPlus = allowsPlus
            option.isRequired = isRequired
            
            // Does this option take an option argument?
            pos = optionString.index(after: pos)
            if pos < optionString.endIndex
                    && optionString[pos] == OptionScanner.takesArgChar {
                option.takesArg = true
                pos = optionString.index(after: pos)

                // The + arg, if it's allowed, is required to mimic its big
                // brother.
                if option.allowsPlus {
                    option.takesPlusArg = true
                }
                
                // Is there a description for this option's argument?
                var posAfterArg: String.Index?
                (option.argDescription, posAfterArg) =
                    getBracketedString(source: optionString,
                           start: pos,
                           leftBracket: OptionScanner.optArgNameLeftBracket,
                           rightBracket: OptionScanner.optArgNameRightBracket)
                if let posAfterArg = posAfterArg /* found a description */ {
                    pos = posAfterArg
                }
                
                if option.allowsPlus {
                    // Try to read a second argument description. If there is
                    // just one, it will have been used already; if there are
                    // none, we'll fail (again) when we look for the second. But
                    // we're good at failing, so we can do it twice.
                    (option.argForAltDescription, posAfterArg) =
                        getBracketedString(source: optionString,
                               start: pos,
                               leftBracket: OptionScanner.optArgNameLeftBracket,
                               rightBracket: OptionScanner.optArgNameRightBracket)
                    if let posAfterArg = posAfterArg {
                        pos = posAfterArg
                    }
                }
            }
            
        }
    }
    
    
    // When all the options have been read, it's time to build the option lists
    // from the "options" dictionary and the "users" list. This has to happen
    // before usage strings can be prepared and before the command-line
    // arguments have been scanned. But usage strings are optional while
    // argument scanning is not, so we have to be able to run the list-building
    // process more than once.
    
    // Build allOptions, creatorOptions, and each OptionUser's option lists.
    func buildOptionLists() {
        // Has it already been done? (See introductory comment for this
        // function.)
        guard stillAcceptingNewUsers else {
            return
        }
        stillAcceptingNewUsers = false
        
        // First, sort the keys in options, and then extract its values into the
        // grand list of all options.
        
        // The Java version sorts the options in a manner that (as I recall)
        // is intended to look like a typical man page. I was going to duck it
        // here, but ... oh, well. It was kind of fun.
        
        // Comparing keys: return true if "one" should come before "two".
        func optionComparator(one: Character, two: Character) -> Bool {
            if one == two {
                return true // arbitrarily
            }
            
            // If either of these two unwrappings fails, it's a programming
            // error.
            let us1 = Unicode.Scalar(String(one))!
            let us2 = Unicode.Scalar(String(two))!
            
            // Classify both characters.
            let oneSpecial = !CharacterSet.alphanumerics.contains(us1)
            // "special" == non-alphanumeric -- really only the characters
            // in extraOptionCharacters
            let twoSpecial = !CharacterSet.alphanumerics.contains(us2)
            let oneLetter = CharacterSet.letters.contains(us1)
            let twoLetter = CharacterSet.letters.contains(us2)
            let oneDigit = CharacterSet.decimalDigits.contains(us1)
            let twoDigit = CharacterSet.decimalDigits.contains(us2)

            // Special characters come first, then letters, then digits.
            // The case both-are-letters is most common and most complicated,
            // so we do it first.
            
            // Ths code is longer than it needs to be (see the Java version),
            // but easier to understand than it could be (see the Java version).
            
            // If they're both letters of the same case, return the usual
            // result.
            if CharacterSet.lowercaseLetters.contains(us1)
                    && CharacterSet.lowercaseLetters.contains(us2) {
                return one <= two
            }
            if CharacterSet.uppercaseLetters.contains(us1)
                    && CharacterSet.uppercaseLetters.contains(us2) {
                return one <= two
            }
            
            // If they're both letters but not of the same case ...
            if oneLetter && twoLetter {
                // The lower-case one goes first, if they're otherwise the same
                let oneLowered = one.lowercased()
                let twoLowered = two.lowercased()
                if oneLowered == twoLowered {
                    return CharacterSet.lowercaseLetters.contains(us1)
                } else {
                    // Otherwise, compare as if case is irrelevant.
                    return oneLowered <= twoLowered
                }
            }
            
            if oneSpecial {
                if twoSpecial {
                    return one <= two
                } else {
                    return true // non-alphanumerics first
                }
            } else if oneLetter {
                if twoSpecial {
                    return false
                } else if twoDigit {
                    return true // letters before digits
                } // We already did the both-are-letters case.
            } else if oneDigit {
                if twoSpecial || twoLetter {
                    return false
                } else {
                    return one <= two
                }
            }
            
            return one <= two // The compiler insisted on this.
        } // end of optionComparator, at last.
        
        // Sort the keys and make allOptions as a sorted list.

        let sortedKeys = options.keys.sorted(by: optionComparator)
        for key in sortedKeys {
            allOptions.append(options[key]!)
        }
        
        // Make the per-user lists of options: (1) initialize ...
        creatorOptions = [Option]()
        for u in 0 ..< users.count {
            users[u].options = [Option]()
        }
        
        // ... (2) accumulate
        for option in allOptions {
            if option.owner != nil {
                option.owner!.options.append(option)
            } else {
                creatorOptions.append(option)
            }
        }
    }

    
    // Return a string describing the correct usage of the selected options,
    // suitable for use as part of a "Usage: ..." error message.
    //
    // If you're not using submodules with their own options, just accept the
    // default: returnSpecificCreatorOptions == true.
    //
    // If you are using submodules with their own options:
    //
    // - change the default to false, to have the returned string include all
    //   the options together: the main program's and all the submodules.
    //
    // - keep the default as true, to get a returned string that includes only
    //   the options for the creator (main) program. Now you can prepare a more
    //   elegant usage message that separates main and sub-options.
    //
    // With either setting, all the submodules have their usageString members
    // set and their notifyUsageStringReady() function called.
    //
    // The returned string lists the options in the usual Unix man-page order:
    // options that do not take arguments before those that do, and required
    // "options" before optional options.
    //
    // This function was called "getUsageString" in the Java version.
    //
    // Parameter:
    //  returnSpecificCreatorOptions: false to return a combined usage string
    //  for the creator's options and all the OptionUsers' options together
    //
    // Returns: a String describing the usage of the creator's options (or of
    //  all the options together, if returnSpecificCreatorOptions is false)
    //
    // Side effect: sets all OptionUsers' "usageString" members, and calls their
    //  notifyUsageStringReady() functions.

    public func usageString(returnSpecificCreatorOptions: Bool = true) -> String
    {
        buildOptionLists()
        
        // Build the OptionUsers' usage strings, and tell them about it.
        // If the main program calls this function twice (presumably once with
        // returnSpecificCreatorOptions true and once with false), this work
        // will be repeated. But it's not a lot, and it's pretty unlikely.
        for u in 0 ..< users.count {
            var user = users[u]
            user.usageString = buildUsageString(list: user.options)
            user.notifyUsageStringReady()
        }
        
        // Return the usage string for the selected option list.
        let list = returnSpecificCreatorOptions ? creatorOptions : allOptions
        return buildUsageString(list: list)
    }
    
    
    // Return the usage string corresponding to a list of Options.
    //
    // Parameter:
    //  list: the list of Options to work from
    //
    // Returns: the string describing list's Options.
    
    func buildUsageString(list: [Option]) -> String {
        
        // Classifying the options according to how they should be grouped in
        // the usage string
        var nonargReqOptions = [Option]()
        var nonargOptions = [Option]()
        var nonargReqPlusOptions = [Option]()
        var nonargPlusOptions = [Option]()
        var argReqOptions = [Option]()
        var argOptions = [Option]()
        // not needed:
        // argReqPlusOptions
        // argPlusOptions
        // -- because if an option takes an argument, then it gets its own
        // section of the usage string. The point of the lists is to allow
        // treating together those options that have similar characteristics,
        // but you can't do that if they take arguments. If an argument is
        // required, we add a whole new part of the usage string; and then if
        // plus is allowed, we add yet another whole new part. There's no need
        // for a separate list.
        
        // Put each option where it belongs.
        for o in list {
            if o.isRequired {
                if o.takesArg {
                    argReqOptions.append(o)
                } else if o.allowsPlus {
                    nonargReqPlusOptions.append(o)
                } else {
                    nonargReqOptions.append(o)
                }
            } else {
                if o.takesArg {
                    argOptions.append(o)
                } else if o.allowsPlus {
                    nonargPlusOptions.append(o)
                } else {
                    nonargOptions.append(o)
                }
            }
        }
        
        // Set up the value to be returned.
        var result = ""
        let minusPrefix = String(minusChar)
        let plusOrMinusPrefix = String(plusChar) + "/" + minusPrefix
        
        // Make and accumulate the various partial strings.
        
        var usagePart: String // repeatedly reused
        func appendOptChar(s: String, o: Option) -> String
            { return s + String(o.optionChar) }
        
        // required non-arg non-plus
        usagePart = nonargReqOptions.reduce("", appendOptChar)
        if !usagePart.isEmpty {
            result += minusPrefix + usagePart
        }
        
        // non-required non-arg non-plus
        usagePart = nonargOptions.reduce("", appendOptChar)
        if !usagePart.isEmpty {
            let addedBlank = result.isEmpty ? "" : " "
            result += addedBlank + "[ " + minusPrefix + usagePart + " ]"
        }
        
        // required non-arg plus
        usagePart = nonargReqPlusOptions.reduce("", appendOptChar)
        if !usagePart.isEmpty {
            let addedBlank = result.isEmpty ? "" : " "
            result += addedBlank + plusOrMinusPrefix + usagePart
        }
        
        // non-required non-arg plus
        usagePart = nonargPlusOptions.reduce("", appendOptChar)
        if !usagePart.isEmpty {
            let addedBlank = result.isEmpty ? "" : " "
            result += addedBlank + "[ " + plusOrMinusPrefix + usagePart + " ]"
        }
        
        // required arg
        
        var descCounter = 1
        if !argReqOptions.isEmpty {
            for o in argReqOptions {
                let argChar = String(o.optionChar)

                var description = o.argDescription // might be nil
                if description == nil || trimWhitespace(description!).isEmpty {
                    description = "optionitem\(descCounter)"
                    descCounter += 1
                }
                
                // usagePart = indPrefix + argChar + " " + description!
                usagePart = "\(minusChar)\(argChar) \(description!)"
                
                if o.allowsPlus {
                    var descPlus = o.argForAltDescription
                    if descPlus == nil || trimWhitespace(descPlus!).isEmpty {
                        descPlus = "optionitem\(descCounter)"
                        // Java version had descPlus = description, using the
                        // same value of the counter for both - and + options.
                        descCounter += 1
                    }
                    
                    usagePart += " | \(plusChar)\(argChar) \(descPlus!)" 
                }

                if !usagePart.isEmpty {
                    if !result.isEmpty {
                        result += " "
                    }
                    result += usagePart
                }
            }
        }
        
        // non-required arg
        // (That is, the option is not required, but if it is present, it does
        // require an argument.)
        
        // continuing use of same descCounter
        if !argOptions.isEmpty {
            for o in argOptions {
                let argChar = String(o.optionChar)

                var description = o.argDescription // might be nil
                if description == nil || trimWhitespace(description!).isEmpty {
                    description = "optionitem\(descCounter)"
                    descCounter += 1
                }
                
                // usagePart = indPrefix + argChar + " " + description!
                usagePart = "\(minusChar)\(argChar) \(description!)"
                
                if o.allowsPlus {
                    var descPlus = o.argForAltDescription
                    if descPlus == nil || trimWhitespace(descPlus!).isEmpty {
                        descPlus = "optionitem\(descCounter)"
                        // Java version had descPlus = description, using the
                        // same value of the counter for both - and + options.
                        descCounter += 1
                    }
                    
                    usagePart += " | \(plusChar)\(argChar) \(descPlus!)" 
                }

                if !usagePart.isEmpty {
                    if !result.isEmpty {
                        result += " "
                    }
                    result += "[ " + usagePart + " ]"
                }
            }
        }
        
        // all done
        return result
    }
    
    
    // Read the options and option arguments from the list of program arguments.
    // Named in honour of C's getopt(), though the plural did seem necessary.
    //
    // This method corresponds to scan() in the Java version. Apart from the
    // name change, there is one important difference: the "arguments" parameter
    // is the *entire* list of command-line arguments, without omitting the
    // first (which is the path to the called program). That first argument is
    // never used, but its presence means that the returned index is greater by
    // 1 than in the Java version. (This design difference is a decision to go
    // along with what Swift gives us in CommandLine.arguments. I hope that this
    // will also make life easier for an OptionScanner's user.)
    //
    // Getting starts from the second element of "args" (index 1), setting
    // option values as they are encountered, until the process is stopped by
    // reaching the last element of args, indicated by reading an obviously
    // non-option argument, or by reading an element equal to optionListEnder
    // ("--").
    //
    // The return value is the index of the first unused argument in args. If
    // "--" terminates the options, then the return value is the index of the
    // argument AFTER the "--".
    //
    // When getting is complete, all the OptionUsers are notified.
    //
    // You can call getOpts more than once, but you cannot reset an
    // OptionScanner, so that would surely be pointless, and it will cause an
    // error if any of the args in the second call are the same as in the first.
    //
    // Parameter:
    //  args: the list of arguments to be scanned
    //
    // Returns: the index of the first element of arguments that does not
    //  specify an option.
    //
    // Throws: OptionError.failedGet if getting fails for any reason.
    //
    // Side effect: sets all OptionUsers' "options" members, and calls their
    //  notifyOptionsReady() functions.
    
    public func getOpts(_ args: [String]) throws -> Int {
        
        buildOptionLists() // in case we didn't make the usage strings already
        
        var argIndex = 1 // Skip argument 0.
        
        while argIndex < args.count {
            let arg = args[argIndex]
            
            // We're at the beginning of a new argument string, which is either
            // just this argument or this one and the next, if the option takes
            // an option argument and it is not included in this argument.
            
            // Is this argument long enough to hold an option? Does its hold at
            // least one option?
            if arg.count < 2 || (arg[arg.startIndex] != minusChar
                                && arg[arg.startIndex] != plusChar) {
                break
            }
            if arg == OptionScanner.optionListEnder {
                argIndex += 1 // Throw away the "--" argument.
                break
            }
            
            var pos = arg.startIndex
            var char = arg[pos]
            
            let plusUsed = char == plusChar
            
            // Examine all the characters in arg
            pos = arg.index(after: pos)
            while pos < arg.endIndex {
                char = arg[pos]
                
                // Which option are we setting?
                let key = char
                guard let option = options[key] else {
                    throw OptionError.failedGet(
                        "option '\(key)' not recognized")
                }
                
                // Are we setting the option with plus?
                if plusUsed && !option.allowsPlus {
                    throw OptionError.failedGet(
                    "'\(plusChar)' used with option '\(key)'")
                }
                
                // Tell the option that it has been set.
                if !plusUsed {
                    if option.isSet {
                        throw OptionError.failedGet("option '\(key)' set twice")
                    } else {
                        option.isSet = true
                    }
                } else { // set with plus
                    if option.isSetWithAlt {
                        throw OptionError.failedGet("option '\(key)' set twice")
                    } else {
                        // Failure will be a failedGet; we just pass it along.
                        try option.setWithPlus()
                    }
                }
                
                // If the option takes an option argument, extract it --
                // possibly from the next (command-line) argument.
                if option.takesArg {
                    if pos > arg.index(arg.startIndex, offsetBy: 1) {
                        throw OptionError.failedGet(
                            "option '\(key)' not first in argument")
                    }
                    
                    // Extract the option argument.
                    var value: String
                    pos = arg.index(after: pos)
                    if pos < arg.index(arg.endIndex, offsetBy: -1) {
                        value = String(arg[pos ..< arg.endIndex])
                    } else {
                        // Option argument is in next command-line argument.
                        argIndex += 1
                        if argIndex == args.count {
                            throw OptionError.failedGet("""
missing argument for option '\(key)'
""")
                        }
                        value = args[argIndex]
                    }
                    
                    // Save the option argument.
                    if !plusUsed {
                        try option.setArg(arg: value) // might throw; that's OK
                    } else {
                        try option.setPlusArg(arg: value) // might throw
                    }
                    
                    // We're done with this command-line argument (CLA). Either
                    // the option argument was the trailing part of the CLA, or
                    // we moved on to the next CLA and used it up completely.
                    break
                }
                
                // Go on to the next command-line argument.
                pos = arg.index(after: pos)
            }
            
            argIndex += 1 // We're done with this argument.
        }
        
        // Check that required options have been set.
        for (char, option) in options {
            if option.isRequired && !option.isSet
                && !(option.allowsPlus && option.isSetWithAlt)
            {
                throw OptionError.failedGet("required option '\(char)' not set")
            }
        }
        
        // Tell the users that we've finished scanning.
        for user in users {
            user.notifyOptionsReady()
        }
        
        return argIndex
    }

}
