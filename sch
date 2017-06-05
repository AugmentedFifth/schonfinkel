#!/usr/bin/env node

"use strict";

const fs = require("fs");


const codepage =
    "⊛→←≡≢¬⊙⩖⤔∈\n⁂⅋≫≪∩∪Σ↵⊢¦∀∃⟨⟩¡⟥Δ⌊×⊠÷ !\"#$%&'()*+,-./0123456789:;<=>" +
    "?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~⋄";

const specialFnMappings = {
    "⊛": "App.<*>",
    "≡": "P.==",
    "≢": "P./=",
    "¬": "P.not",
    "⊙": "`L.findIndices`",
    "⩖": "&!&!&",
    "⤔": "`M.mapM`",
    "∈": "`P.elem`",
    "⁂": "Arr.***",
    "⅋": "Arr.&&&",
    "∩": "`L.intersect`",
    "∪": "`L.union`",
    "Σ": "P.sum",
    "↵": "App.<$>",
    "⊢": "`L.partition`",
    "∀": "`P.all`",
    "∃": "`P.any`",
    "¡": "`L.genericIndex`",
    "Δ": "^-^-^",
    "×": "!>^<!",
    "⊠": "`L.zip`",
    "÷": "`P.div`",
    "⋄": "+:+:+"
};

const infixFnMappings = {
    "^≫": "Arr.^>>",
    "≫":  "M.>>",
    "≫=": "M.>>=",
    "≫>": "Arr.>>>",
    "≫^": "Arr.>>^",
    "^≪": "Arr.^<<",
    "≪<": "Arr.<<<",
    "≪^": "Arr.<<^",
    "=≪": "M.=<<",
    "⌊":  "P.floor",
    "⌊^": "P.ceiling",
    "⌊#": "P.round",
    "⌊!": "P.truncate",
    "$":  "P.$",
    "%":  "`P.mod`",
    "*":  "P.*",
    "+":  "P.+",
    ".":  "P..",
    "/":  "P./",
    ":":  "P.:",
    "<":  "P.<",
    ">":  "P.>",
    "^":  "P.^",
    "*>": "App.*>",
    "**": "P.**",
    "++": "P.++",
    "<=": "P.<=",
    "<$": "App.<$",
    "<*": "App.<*",
    "^^": "P.^^"
};

const upperIdMappings = {
    "A":  "L.filter",
    "AR": "Arr.arr",
    "B":  "L.sortBy",
    "BR": "L.break",
    "C":  "F.concat",
    "CG": "O.comparing",
    "CM": "O.compare",
    "CO": "P.cos",
    "CR": "P.curry",
    "CY": "L.cycle",
    "D":  "L.nub",
    "DR": "L.genericDrop",
    "DW": "L.dropWhile",
    "E":  "F.maximum",
    "ER": "P.error",
    "EV": "P.even",
    "EX": "P.exp",
    "F":  "L.zipWith",
    "FC": "unsafeFind",
    "FD": "F.find",
    "FH": "findIndex1",
    "FI": "L.findIndex",
    "FJ": "May.fromJust",
    "FL": "L.foldl1'",
    "FM": "May.fromMaybe",
    "FP": "P.flip",
    "FR": "F.foldr1",
    "FT": "P.fst",
    "G":  "F.minimum",
    "GC": "P.getChar",
    "GD": "P.gcd",
    "GL": "P.getLine",
    "H":  "P.toEnum",
    "I":  "F.null",
    "IE": "L.iterate",
    "IJ": "May.isJust",
    "IN": "May.isNothing",
    "IR": "P.interact",
    "J":  "L.tail",
    "K":  "L.genericTake",
    "L":  "L.genericLength",
    "LA": "L.last",
    "LG": "P.log",
    "LI": "P.lines",
    "LM": "P.lcm",
    "LU": "L.lookup",
    "LV": "unsafeLookup",
    "M":  "P.show",
    "MI": "mapWithIndices",
    "N":  "P.read",
    "NE": "F.notElem",
    "O":  "P.fromEnum",
    "OD": "P.odd",
    "P":  "P.print",
    "PI": "P.pi",
    "PR": "P.pred",
    "PS": "P.putStrLn",
    "PT": "P.putStr",
    "Q":  "subIndex",
    "QT": "P.quot",
    "R":  "L.reverse",
    "RC": "L.genericReplicate",
    "RF": "P.readFile",
    "RM": "P.rem",
    "RP": "L.repeat",
    "RT": "M.return",
    "S":  "L.sort",
    "SD": "P.snd",
    "SI": "P.sin",
    "SL": "L.scanl1",
    "SN": "L.span",
    "SP": "L.genericSplitAt",
    "SQ": "M.sequence",
    "SR": "L.scanr",
    "SS": "L.scanr1",
    "ST": "P.sqrt",
    "SU": "P.succ",
    "T":  "L.transpose",
    "TA": "P.tan",
    "U":  "L.intercalate",
    "UC": "P.uncurry",
    "UD": "P.undefined",
    "UL": "P.unlines",
    "UT": "P.until",
    "UW": "P.unwords",
    "UZ": "L.unzip",
    "V":  "L.scanl",
    "W":  "L.takeWhile",
    "WF": "P.writeFile",
    "WO": "P.words",
    "X":  "F.foldl'",
    "Y":  "F.foldr",
    "Z":  "L.permutations",
    "ZT": "L.zip3",
    "ZU": "L.unzip3",
    "ZW": "L.zipWith3"
};

/* Ordered by precedence */
const lineFeed = /^\n+/;
const charLiteral = /^'[^\n]'/;
const strLiteral = /^"[^\n]*"/;
const blockComment = /^{-.*-}/;
const lineComment = /^--[^\n]*/;
const spacing = /^ +/;
const rightArr = /^→/;
const leftArr = /^←/;
const do_ = /^⟥/;
const doubleDots = /^\.\.(?=[^!#\$%&*+./:<=>?@\\^|~-])/;
const numericLiteral = /^[0-9]*\.?[0-9]+/;
const eqBinding = /^=(?=[^!#\$%&*+./:<=>?@\\^|~-])/;
const semicolon = /^;/;
const backtick = /^`/;
const leftParen = /^\(/;
const rightParen = /^\)/;
const leftCurBracket = /^{/;
const rightCurBracket = /^}/;
const leftSqBracket = /^\[/;
const rightSqBracket = /^\]/;
const leftAngBracket = /^⟨/;
const rightAngBracket = /^⟩/;
const comma = /^,/;
const asAt = /^@(?=[^!#\$%&*+./:<=>?@\\^|~-])/;
const vert = /^\|/;
const brokenVert = /^¦/;
const unaryMinus = /^-(?=[^!#\$%&*+./:<=>?@\\^|~-])/;
const underscore = /^_/;
const specialFn = /^[⊛≡≢¬⊙⩖⤔∈⁂⅋∩∪Σ↵⊢∀∃¡Δ×⊠÷⋄]/;
const infixFn = /^(\^≫|≫|≫=|≫>|≫\^|\^≪|≪<|≪\^|=≪|⌊|⌊\^|⌊#|⌊!|[!#\$%&*+./:<=>?@\\^|~\-]+)/;
const upperId = /^[A-Z]+/;
const lowerId = /^[a-z]+/;
const regexes =
    [ lineFeed
    , charLiteral
    , strLiteral
    , blockComment
    , lineComment
    , spacing
    , rightArr
    , leftArr
    , do_
    , doubleDots
    , numericLiteral
    , eqBinding
    , semicolon
    , backtick
    , leftParen
    , rightParen
    , leftCurBracket
    , rightCurBracket
    , leftSqBracket
    , rightSqBracket
    , leftAngBracket
    , rightAngBracket
    , comma
    , asAt
    , vert
    , brokenVert
    , unaryMinus
    , underscore
    , specialFn
    , infixFn
    , upperId
    , lowerId
    ];

const usage = `\
Usage:
======

sch -c <inputFile> [outputFile]    Compiles a Schönfinkel source
                                   file using the Schönfinkel
                                   codepage, outputting to an *.hs
                                   file or instead to the
                                   optionally supplied output file.

sch -u <inputFile> [outputfile]    Same as above, but uses Unicode
                                   (UTF-8) encoding instead.

For more info, visit https://github.com/AugmentedFifth/schonfinkel`;

function nameOutput(inputName) {
    const split = inputName.split(".");

    if (split.length > 1) {
        return split.slice(0, -1).join(".") + ".hs";
    }
    return inputName + ".hs";
}

function schDecode(buf) {
    const decoded = [];

    for (const b of buf) {
        decoded.push(codepage[b]);
    }

    return decoded.join("");
}


if (process.argv.length < 4) {
    console.log(usage);
    process.exit(1);
}

const flag = process.argv[2];
const inputFile = process.argv[3];
const outputFile =
    process.argv.length > 4 ?
        process.argv[4] :
        nameOutput(inputFile);

const unicode = (() => {
    switch (flag) {
        case "-c":
            return false;
        case "-u":
            return true;
        default:
            console.log(usage);
            process.exit(1);
    }
})();

const input = fs.readFileSync(inputFile, unicode ? "utf8" : undefined);

let code =
    unicode ?
        input.split("").filter(c => ~codepage.indexOf(c)).join("") :
        schDecode(input);

// ============ Begin compilation ============ //

/* Tokenization */

const tokens = [[]];

while (code.length > 0) {
    let matched = false;

    for (const regex of regexes) {
        const match = regex.exec(code);
        if (match === null) {
            continue;
        }

        const matchStr = match[0];
        code = code.slice(matchStr.length);

        if (~matchStr.indexOf("\n")) {
            if (tokens[tokens.length - 1].length > 0) {
                tokens.push([]);
            }
        } else if (!spacing.test(matchStr)) {
            tokens[tokens.length - 1].push(matchStr);
        }

        matched = true;
        break;
    }

    if (!matched) {
        console.log("Encountered unexpected character: " + code[0]);
        console.log("Context:\n");
        console.log("    " + tokens[tokens.length - 1].join(" "));
        process.exit(1);
    }
}

if (tokens[tokens.length - 1].length < 1) {
    tokens.pop();
}

/* Hacky parsing directly into Haskell */

let out = `\
import qualified Control.Monad       as M
import qualified Control.Applicative as App
import qualified Control.Arrow       as Arr

import qualified Data.Foldable       as F
import qualified Data.List           as L
import qualified Data.Maybe          as May
import qualified Data.Ord            as O

import qualified Prelude             as P
`;
const calls = [];

tokens.forEach(l => {
    function failWithContext(msg) {
        if (msg) {
            console.log(msg);
        } else {
            console.log("Parsing failure.");
        }
        console.log("Context:\n");
        console.log("    " + l.join(" "));
        process.exit(1);
    }

    let line = "";

    let backtickFlag = false;
    let doFlag = false;
    let parenScope = 0;
    let letScope = 0;
    let squareScope = 0;

    l.forEach(token => {
        if (backtickFlag && !(upperId.test(token) || lowerId.test(token))) {
            failWithContext("Illegal use of backtick: `" + token);
        }

        if (
            charLiteral.test(token) ||
            strLiteral.test(token)  ||
            numericLiteral.test(token)
        ) {
            line += token + " ";
        } else if (blockComment.test(token) || spacing.test(token)) {
            line += " ";
        } else if (rightArr.test(token)) {
            line += "-> ";
        } else if (leftArr.test(token)) {
            line += "<- ";
        } else if (do_.test(token)) {
            line += "(do ";
            doFlag = true;
        } else if (".." === token) {
            line += ".. ";
        } else if ("=" === token) {
            line += "= ";
        } else if (";" === token) {
            if (doFlag) {
                line += "; ";
            } else {
                line += " ";
            }
            // TODO: rest of the semicolon semantics?
        } else if ("`" === token) {
            line += "`";
            backtickFlag = true;
        } else if ("(" === token) {
            line += "( ";
            parenScope++;
        } else if (")" === token) {
            line += ") ";
            parenScope--;
            if (parenScope < 0) {
                failWithContext("Mismatched parentheses.");
            }
        } else if ("{" === token) {
            line += "let ";
            letScope++;
        } else if ("}" === token) {
            line += "in ";
            letScope--;
            if (letScope < 0) {
                failWithContext("Mismatched let blocks.");
            }
        } else if ("[" === token) {
            line += "[ ";
            squareScope++;
        } else if ("]" === token) {
            // TODO: square bracket semantics
        } else if ("⟨" === token) {
            // TODO: angle bracket semantics
        } else if ("⟩" === token) {
            // TODO: angle bracket semantics
        } else if (comma.test(token)) {
            line += token + " ";
            // TODO: extra comma semantics
        } else if ("@" === token) {
            line += "@ ";
        } else if ("|" === token) {
            // TODO: full pipe semantics
        } else if ("¦" === token) {
            // TODO: broken pipe semantics
        } else if ("-" === token) {
            line += "P.negate ";
        } else if ("_" === token) {
            line += "_ ";
        } else if (specialFn.test(token)) {
            const callName = specialFnMappings[token];
            line += callName + " ";
            calls.push(callName);
        } else if (infixFn.test(token)) {
            const callName =
                token in infixFnMappings ?
                    infixFnMappings[token] :
                    token;
            line += callName + " ";
            calls.push(callName);
        } else if (upperId.test(token)) {
            const callName = upperIdMappings[token];

            if (!callName) {
                failWithContext("No such built-in defined: " + token);
            }

            line += callName + (backtickFlag ? "` " : " ");
            backtickFlag = false;
            calls.push(callName);
        } else if (lowerId.test(token)) {
            line += token + " ";
        }
    });

    if (parenScope !== 0) {
        failWithContext("Mismatched parentheses.");
    }
    if (letScope !== 0) {
        failWithContext("Mismatched let blocks.");
    }
    if (squareScope !== 0) {
        failWithContext("Mismatched square brackets.");
    }

    if (backtickFlag) {
        line += "`";
    }

    out += line;
    out += "\n\n";
});


/* Semantic tagging */


