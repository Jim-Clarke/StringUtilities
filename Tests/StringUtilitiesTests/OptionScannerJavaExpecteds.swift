//
//  File.swift
//  
//
//  Created by Jim Clarke on 2021-04-13.
//

import Foundation

// Common changes
//
// Most of these are the result of changed error messages -- though Change B is
// caused by an actual change in how unlabelled option arguments should be
// handled in usage strings.
//
// Some cases needed the output to be reordered because of how subusers
// interact with the scanner and the main user (which is different in Swift
// from Java): cases 52, 53 
//
// Change A:
// " ? plus set: exception: plus queried on non-plus option 'a'"
// replaced with -->  " ? plus set: no"
// (eventually, changed throughout)
//
// Change B:
// Where there are plus-arg arguments with the same name (usually a repeated
// "optionitem" with the same number, but sometimes an actual name), edited
// second name.
//
// Change C:
// "option string too short" --> "option string "ab+!" ended prematurely"
//
// Change D:
// "bad option character '-'" --> "bad character '-' in option string "-ab""
//
// Change E:
// Multiple lines like " ? set: exception: queried option 'a' not recognized"
// --> single line like: "exception: queried nil option"
// (only in Case 4, I think)
//
// Change F:
// "duplicate option character 'a'" --> appended " in option string "ab+a:""
//
// Change G:
// "plus used with option 's'" --> "'+' used with option 's'"
//
// Change H:
// "option 'x' missing argument" --> "missing argument for option 'x'"
//
// Change H:
// "queried option 'x' had null argument"
// --> "option argument queried on unset option 'x'"
// "queried option 'z' had null argument"
// --> "plus option argument queried on unset option 'z'"

let simpleExpecteds: [String] = [

"Case 0\n", // There is no Case 0.

"""
Case 1
option string: "ab:c"
entire usage string: "[ -ac ] [ -b optionitem1 ]"
usage string for main: "[ -ac ] [ -b optionitem1 ]"
command-line arguments: "-a" "-b" "jim"
arguments scanned: 3
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: "jim"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'
'c' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'c'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'c'

""", // Change A * 3

"""
Case 2
option string: "dc!b:<item name>+a"
entire usage string: "[ -cd ] [ +/-a ] -b item name"
usage string for main: "[ -cd ] [ +/-a ] -b item name"
command-line arguments: "-c" "-a" "-bjim" "+a" "--" "filename"
arguments scanned: 5
'a' ...
 ? set: yes
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: "jim"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'
'c' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'c'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'c'
'd' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'd'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'd'

""", // Change A * 3

"""
Case 3
option string: "zH2#1hbR?"
entire usage string: "[ -#?bhHRz12 ]"
usage string for main: "[ -#?bhHRz12 ]"
command-line arguments: "-?H" "-zb1#" "nonoption"
arguments scanned: 2
'#' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option '#'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '#'
'?' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option '?'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '?'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'
'h' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'h'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'h'
'H' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'H'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'H'
'R' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'R'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'R'
'z' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'z'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'z'
'1' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option '1'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '1'
'2' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option '2'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '2'

""", // Change A * 9

    // No more counting the A changes: done throughout from here

"""
Case 4
option string: ""
entire usage string: ""
usage string for main: ""
command-line arguments: "-a" "-"
exception while scanning: option 'a' not recognized
'a' ...
exception: queried nil option

""",

"""
Case 5
option string: "+k+K+3+4+?+#"
entire usage string: "[ +/-#?kK34 ]"
usage string for main: "[ +/-#?kK34 ]"
command-line arguments: "-k" "+K" "+34" "+"
arguments scanned: 3
'#' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option '#'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '#'
'?' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option '?'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '?'
'k' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'k'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'k'
'K' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'K'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'K'
'3' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option '3'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '3'
'4' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option '4'
 ? plus arg: exception: plus option argument queried on non-plus-arg option '4'

""",

"""
Case 6
option string: "!a"
entire usage string: "-a"
usage string for main: "-a"
command-line arguments: "-a" "z"
arguments scanned: 1
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'

""",

"""
Case 7
option string: "!az!wd"
entire usage string: "-aw [ -dz ]"
usage string for main: "-aw [ -dz ]"
command-line arguments: "-awd" ""
arguments scanned: 1
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'd' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'd'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'd'
'w' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'w'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'w'
'z' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'z'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'z'

""",

"""
Case 8
option string: "+!h+!g+!w"
entire usage string: "+/-ghw"
usage string for main: "+/-ghw"
command-line arguments: "-h" "+g" "+w" "-w"
arguments scanned: 4
'g' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'g'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'g'
'h' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'h'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'h'
'w' ...
 ? set: yes
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'w'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'w'

""",

"""
Case 9
option string: "+!g+h"
entire usage string: "+/-g [ +/-h ]"
usage string for main: "+/-g [ +/-h ]"
command-line arguments: "+h" "+g" "-"
arguments scanned: 2
'g' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'g'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'g'
'h' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'h'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'h'

""",

"""
Case 10
option string: "a:b:"
entire usage string: "[ -a optionitem1 ] [ -b optionitem2 ]"
usage string for main: "[ -a optionitem1 ] [ -b optionitem2 ]"
command-line arguments: "-a" "-b"
arguments scanned: 2
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: "-b"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on unset option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

""",

"""
Case 11
option string: "!a:!b:"
entire usage string: "-a optionitem1 -b optionitem2"
usage string for main: "-a optionitem1 -b optionitem2"
command-line arguments: "-ahi" "-b" "there"
arguments scanned: 3
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: "hi"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: "there"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

""",

"""
Case 12
option string: "a:!b:"
entire usage string: "-b optionitem1 [ -a optionitem2 ]"
usage string for main: "-b optionitem1 [ -a optionitem2 ]"
command-line arguments: "-b" "there"
arguments scanned: 2
'a' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on unset option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: "there"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

""",

"""
Case 13
option string: "+a:+b:<first>+c:<second><third>+d:"
entire usage string: "[ -a optionitem1 | +a optionitem2 ] [ -b first | +b optionitem3 ] [ -c second | +c third ] [ -d optionitem4 | +d optionitem5 ]"
usage string for main: "[ -a optionitem1 | +a optionitem2 ] [ -b first | +b optionitem3 ] [ -c second | +c third ] [ -d optionitem4 | +d optionitem5 ]"
command-line arguments: "-aone" "+c" "two" "+b" "three" "-c" "four"
arguments scanned: 7
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: "one"
 ? plus arg: exception: plus option argument queried on unset option 'a'
'b' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on unset option 'b'
 ? plus arg: "three"
'c' ...
 ? set: yes
 ? plus set: yes
 ? arg: "four"
 ? plus arg: "two"
'd' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on unset option 'd'
 ? plus arg: exception: plus option argument queried on unset option 'd'

""",

"""
Case 14
option string: "+!a:+!b:<first>+!c:<second><third>+!d:"
entire usage string: "-a optionitem1 | +a optionitem2 -b first | +b optionitem3 -c second | +c third -d optionitem4 | +d optionitem5"
usage string for main: "-a optionitem1 | +a optionitem2 -b first | +b optionitem3 -c second | +c third -d optionitem4 | +d optionitem5"
command-line arguments: "-aone" "-c" "two" "+c" "four" "+b" "three" "-dwhatever"
arguments scanned: 8
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: "one"
 ? plus arg: exception: plus option argument queried on unset option 'a'
'b' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on unset option 'b'
 ? plus arg: "three"
'c' ...
 ? set: yes
 ? plus set: yes
 ? arg: "two"
 ? plus arg: "four"
'd' ...
 ? set: yes
 ? plus set: no
 ? arg: "whatever"
 ? plus arg: exception: plus option argument queried on unset option 'd'

""",

"""
Case 15
option string: "+9:+!#:"
entire usage string: "-# optionitem1 | +# optionitem2 [ -9 optionitem3 | +9 optionitem4 ]"
usage string for main: "-# optionitem1 | +# optionitem2 [ -9 optionitem3 | +9 optionitem4 ]"
command-line arguments: "+#there"
arguments scanned: 1
'9' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on unset option '9'
 ? plus arg: exception: plus option argument queried on unset option '9'
'#' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on unset option '#'
 ? plus arg: "there"

""",

"""
Case 16
option string: "ab:+?:+9"
entire usage string: "[ -a ] [ +/-9 ] [ -? optionitem1 | +? optionitem2 ] [ -b optionitem3 ]"
usage string for main: "[ -a ] [ +/-9 ] [ -? optionitem1 | +? optionitem2 ] [ -b optionitem3 ]"
command-line arguments: "-a" "-a"
exception while scanning: option 'a' set twice
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'

""",

"""
Case 17
option string: "!a!b:+!?:+!9"
entire usage string: "-a +/-9 -? optionitem1 | +? optionitem2 -b optionitem3"
usage string for main: "-a +/-9 -? optionitem1 | +? optionitem2 -b optionitem3"
command-line arguments: "-bhi" "+?there" "-9"
exception while scanning: required option 'a' not set
'a' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'

""",

"""
Case 18
option string: "!ab:+!?:+9"
entire usage string: "-a [ +/-9 ] -? optionitem1 | +? optionitem2 [ -b optionitem3 ]"
usage string for main: "-a [ +/-9 ] -? optionitem1 | +? optionitem2 [ -b optionitem3 ]"
command-line arguments: "-a" "-9" "+?there" "-9"
exception while scanning: option '9' set twice

""",

"""
Case 19
option string: "+a+b:<one><two>+8z:"
entire usage string: "[ +/-a8 ] [ -b one | +b two ] [ -z optionitem1 ]"
usage string for main: "[ +/-a8 ] [ -b one | +b two ] [ -z optionitem1 ]"
command-line arguments: "+a" "+a"
exception while scanning: option 'a' set twice

""",

"""
Case 20
option string: "a+b:<one><two>8z:"
entire usage string: "[ -a8 ] [ -b one | +b two ] [ -z optionitem1 ]"
usage string for main: "[ -a8 ] [ -b one | +b two ] [ -z optionitem1 ]"
command-line arguments: "-z" "hi" "-z" "again"
exception while scanning: option 'z' set twice

""",

"""
Case 21
option string: "+h:<a><b>9+Y"
entire usage string: "[ -9 ] [ +/-Y ] [ -h a | +h b ]"
usage string for main: "[ -9 ] [ +/-Y ] [ -h a | +h b ]"
command-line arguments: "-h" "hi" "-h" "again"
exception while scanning: option 'h' set twice

""",

"""
Case 22
option string: "+h:<a><b>"
entire usage string: "[ -h a | +h b ]"
usage string for main: "[ -h a | +h b ]"
command-line arguments: "+h" "hi" "+h" "again"
exception while scanning: option 'h' set twice

""",

"""
Case 23
option string: "+!p"
entire usage string: "+/-p"
usage string for main: "+/-p"
command-line arguments:
exception while scanning: required option 'p' not set

""",

"""
Case 24
option string: "!q:"
entire usage string: "-q optionitem1"
usage string for main: "-q optionitem1"
command-line arguments:
exception while scanning: required option 'q' not set

""",

"""
Case 25
option string: "+!r:"
entire usage string: "-r optionitem1 | +r optionitem2"
usage string for main: "-r optionitem1 | +r optionitem2"
command-line arguments:
exception while scanning: required option 'r' not set

""",

"""
Case 26
option string: "s"
entire usage string: "[ -s ]"
usage string for main: "[ -s ]"
command-line arguments: "+s"
exception while scanning: '+' used with option 's'
's' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 's'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 's'

""",

"""
Case 27
option string: "t:"
entire usage string: "[ -t optionitem1 ]"
usage string for main: "[ -t optionitem1 ]"
command-line arguments: "+t" "hi"
exception while scanning: '+' used with option 't'
't' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on unset option 't'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 't'

""",

"""
Case 28
option string: "u:a"
entire usage string: "[ -a ] [ -u optionitem1 ]"
usage string for main: "[ -a ] [ -u optionitem1 ]"
command-line arguments: "-au" "hi"
exception while scanning: option 'u' not first in argument

""",

"""
Case 29
option string: "+v:b"
entire usage string: "[ -b ] [ -v optionitem1 | +v optionitem2 ]"
usage string for main: "[ -b ] [ -v optionitem1 | +v optionitem2 ]"
command-line arguments: "-bvhi"
exception while scanning: option 'v' not first in argument

""",

"""
Case 30
option string: "+w:+c"
entire usage string: "[ +/-c ] [ -w optionitem1 | +w optionitem2 ]"
usage string for main: "[ +/-c ] [ -w optionitem1 | +w optionitem2 ]"
command-line arguments: "+cwhi"
exception while scanning: option 'w' not first in argument

""",

"""
Case 31
option string: "x:"
entire usage string: "[ -x optionitem1 ]"
usage string for main: "[ -x optionitem1 ]"
command-line arguments: "-x"
exception while scanning: missing argument for option 'x'
'x' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on unset option 'x'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'x'

""",

"""
Case 32
option string: "+y:"
entire usage string: "[ -y optionitem1 | +y optionitem2 ]"
usage string for main: "[ -y optionitem1 | +y optionitem2 ]"
command-line arguments: "-y"
exception while scanning: missing argument for option 'y'
'y' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on unset option 'y'
 ? plus arg: exception: plus option argument queried on unset option 'y'

""",

"""
Case 33
option string: "+z:"
entire usage string: "[ -z optionitem1 | +z optionitem2 ]"
usage string for main: "[ -z optionitem1 | +z optionitem2 ]"
command-line arguments: "+z"
exception while scanning: missing argument for option 'z'
'z' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on unset option 'z'
 ? plus arg: exception: plus option argument queried on unset option 'z'

""",

"""
Case 34
option string: "+5:"
entire usage string: "[ -5 optionitem1 | +5 optionitem2 ]"
usage string for main: "[ -5 optionitem1 | +5 optionitem2 ]"
command-line arguments: "-5hi" "+5"
exception while scanning: missing argument for option '5'
'5' ...
 ? set: yes
 ? plus set: yes
 ? arg: "hi"
 ? plus arg: exception: plus option argument queried on unset option '5'

""",

"""
Case 35
option string: "aba"
exception while creating scanner: duplicate option character 'a' in option string "aba"

""",

"""
Case 36
option string: "ab+a"
exception while creating scanner: duplicate option character 'a' in option string "ab+a"

""",

"""
Case 37
option string: "+aba:"
exception while creating scanner: duplicate option character 'a' in option string "+aba:"

""",

"""
Case 38
option string: "ab+a:"
exception while creating scanner: duplicate option character 'a' in option string "ab+a:"

""",

"""
Case 39
option string: "ab<desc>"
exception while creating scanner: bad character '<' in option string "ab<desc>"

""",

"""
Case 40
option string: "a+b<desc>"
exception while creating scanner: bad character '<' in option string "a+b<desc>"

""",

"""
Case 41
option string: "ab:<desc><another>"
exception while creating scanner: bad character '<' in option string "ab:<desc><another>"

""",

"""
Case 42
option string: "a+b:<desc><another><three>"
exception while creating scanner: bad character '<' in option string "a+b:<desc><another><three>"

""",

"""
Case 43
option string: "ab*c"
exception while creating scanner: bad character '*' in option string "ab*c"

""",

"""
Case 44
option string: "ab:<desc> c"
exception while creating scanner: bad character ' ' in option string "ab:<desc> c"

""",

"""
Case 45
option string: "a!+b"
exception while creating scanner: bad character '+' in option string "a!+b"

""",

"""
Case 46
option string: "-ab"
exception while creating scanner: bad character '-' in option string "-ab"

""",

"""
Case 47
option string: "ab-"
exception while creating scanner: bad character '-' in option string "ab-"

""",

"""
Case 48
option string: "ab+"
exception while creating scanner: option string "ab+" ended prematurely

""",

"""
Case 49
option string: "ab!"
exception while creating scanner: option string "ab!" ended prematurely

""",

"""
Case 50
option string: "ab+!"
exception while creating scanner: option string "ab+!" ended prematurely

""",

"""
Case 51
option string: "a+bc:<one>+d:<two><three>"
entire usage string: "[ /a ] [ +//b ] [ /c one ] [ /d two | +d three ]"
usage string for main: "[ /a ] [ +//b ] [ /c one ] [ /d two | +d three ]"
command-line arguments: "/ab" "+b" "/cfirst" "/d" "second" "+dthird"
arguments scanned: 6
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'
'c' ...
 ? set: yes
 ? plus set: no
 ? arg: "first"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'c'
'd' ...
 ? set: yes
 ? plus set: yes
 ? arg: "second"
 ? plus arg: "third"

""",

// Case 52: output reordered to fit calling order in Swift version (subuser
// usage strings not available until main user string created; same for scan
// results).
"""
Case 52
option string: "cyz"
entire usage string: "[ -abcxyz ] [ +/-d ] [ -e 2's arg ]"
usage string for main: "[ -cyz ]"
command-line arguments: "-adc" "+d" "-zx" "-ehi"
arguments scanned: 4
'c' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'c'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'c'
'y' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'y'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'y'
'z' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'z'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'z'
usage string for OptionUser "abx": "[ -abx ]"
usage string for OptionUser "+de:<2's arg>": "[ +/-d ] [ -e 2's arg ]"
OptionUser "abx" notified; report:
-----
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'
'x' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'x'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'x'
--- end of report from OptionUser "abx"
OptionUser "+de:<2's arg>" notified; report:
-----
'd' ...
 ? set: yes
 ? plus set: yes
 ? arg: exception: option argument queried on non-arg option 'd'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'd'
'e' ...
 ? set: yes
 ? plus set: no
 ? arg: "hi"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'e'
--- end of report from OptionUser "+de:<2's arg>"

""",

// Case 53: output reordered as in Case 52.
"""
Case 53
option string: ""
entire usage string: "[ -g ] [ -f a | +f b ]"
usage string for main: ""
command-line arguments: "+f" "boo" "-g" "ehi"
arguments scanned: 3
'f' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on unset option 'f'
 ? plus arg: "boo"
'g' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'g'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'g'
usage string for OptionUser "+f:<a><b>g": "[ -g ] [ -f a | +f b ]"
OptionUser "+f:<a><b>g" notified; report:
-----
'f' ...
 ? set: no
 ? plus set: yes
 ? arg: exception: option argument queried on unset option 'f'
 ? plus arg: "boo"
'g' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'g'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'g'
--- end of report from OptionUser "+f:<a><b>g"

""",

"""
Case 54
option string: "j:<what>"
entire usage string: "[ -j what ]"
usage string for main: "[ -j what ]"
command-line arguments: "-jjim"
arguments scanned: 1
'j' ...
 ? set: yes
 ? plus set: no
 ? arg: "jim"
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'j'
usage string for OptionUser "": ""
OptionUser "" notified; report:
-----
--- end of report from OptionUser ""

""",

// Case 55: exception output deleted, because it's covered by the
// XCTAssertThrowsError() call.
"""
Case 55
option string: "ab"
user: OptionUser "ac"

""",

// Case 56: exception output deleted as in Case 55.
"""
Case 56
option string: ""
first user: OptionUser "ac"
second user: OptionUser "+cd"

""",

// Case 57: exception output deleted (twice) as in Case 55.
"""
Case 57
option string: "ab"
entire usage string: "[ -ab ]"
usage string for main: "[ -ab ]"
command-line arguments: "-a"
arguments scanned: 1
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: no
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

command-line arguments: "-b"
arguments scanned: 1
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

command-line arguments: "-a"
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

command-line arguments: "-b"
'a' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'a'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'a'
'b' ...
 ? set: yes
 ? plus set: no
 ? arg: exception: option argument queried on non-arg option 'b'
 ? plus arg: exception: plus option argument queried on non-plus-arg option 'b'

""",

]
