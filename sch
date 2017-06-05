#!/usr/bin/env node

"use strict";

const fs = require("fs");


const codepage =
    "⊛→←≡≢¬⊙⩖⤔∈\n⁂⅋≫≪∩∪Σ↵⊢¦∀∃⟨⟩¡⟥Δ⌊×⊠÷ !\"#$%&'()*+,-./0123456789:;<=>" +
    "?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~⋄";

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
const infixFn = /^(\^≫|≫|≫=|≫>|≫\^|\^≪|≪<|≪\^|⌊|⌊\^|⌊#|⌊!|[!#\$%&*+./:<=>?@\\^|~\-]+)/;
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

let out = "";




/* Semantic tagging */


