#!/usr/bin/env node

"use strict";

const fs = require("fs");


const codepage =
    "⊛→←≡≢¬⊙⩖⤔∈\n⁂⅋≫≪∩∪Σ↵⊢¦∀∃⟨⟩¡⟥Δ⌊×⊠÷ !\"#$%&'()*+,-./0123456789:;<=>" +
    "?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~⋄";

/* Ordered by precedence */
const lineFeed = /\n+/m;
const charLiteral = /'[^\n]'/m;
const strLiteral = /"[^\n]*"/m;
const blockComment = /{-.*-}/m;
const lineComment = /--[^\n]*/m;
const spacing = / +/m;
const rightArr = /→/m;
const leftArr = /←/m;
const do_ = /⟥/m;
const doubleDots = /\.\.(?=[^!#\$%&*+./:<=>?@\\^|~-])/m;
const numericLiteral = /[0-9]*\.?[0-9]+/m;
const eqBinding = /=(?=[^!#\$%&*+./:<=>?@\\^|~-])/m;
const semicolon = /;/m;
const backtick = /`/m;
const leftParen = /\(/m;
const rightParen = /\)/m;
const leftCurBracket = /{/m;
const rightCurBracket = /}/m;
const leftSqBracket = /\[/m;
const rightSqBracket = /\]/m;
const leftAngBracket = /⟨/m;
const rightAngBracket = /⟩/m;
const comma = /,/m;
const asAt = /@(?=[^!#\$%&*+./:<=>?@\\^|~-])/m;
const vert = /\|/m;
const brokenVert = /¦/m;
const unaryMinus = /-(?=[^!#\$%&*+./:<=>?@\\^|~-])/m;
const underscore = /_/m;
const specialFn = /[⊛≡≢¬⊙⩖⤔∈⁂⅋∩∪Σ↵⊢∀∃¡Δ×⊠÷⋄]/m;
const infixFn = /(\^≫|≫|≫=|≫>|≫\^|\^≪|≪<|≪\^|⌊|⌊\^|⌊#|⌊!|[!#\$%&*+./:<=>?@\\^|~\-]+)/m;
const upperId = /[A-Z]+/m;
const lowerId = /[a-z]+/m;
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
=======

sch -c <inputFile> [outputFile]    Compiles a Schönfinkel source
                                   file using the Schönfinkel
                                   codepage, outputting to an *.hs
                                   file or instead to the
                                   optionally supplied output file.

sch -u <inputFile> [outputfile]    Same as above, but uses Unicode
                                   (UTF-8) encoding instead.`;

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

const code =
    unicode ?
        input.split("").filter(c => ~codepage.indexOf(c)).join("") :
        schDecode(input);

// ============ Begin compilation ============ //

const tokens = [[]];

code.split("").forEach(c => {

});
