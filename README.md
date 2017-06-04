# Schönfinkel

Schönfinkel is a
[pure functional](https://en.wikipedia.org/wiki/Purely_functional_programming),
[statically typed](https://en.wikipedia.org/wiki/Type_system#STATIC) (with full
[type inference](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)),
[non-strictly](https://en.wikipedia.org/wiki/Lazy_evaluation) evaluated
[golfing language](https://en.wikipedia.org/wiki/Code_golf).

Schönfinkel acts as a golfed
["bridge"](https://en.wikipedia.org/wiki/Source-to-source_compiler) to the
[Haskell](https://www.haskell.org/) language.

Schönfinkel is under active development and is by no means a finished product;
as such, expect features to appear and disappear or even changes in semantics
to occur without prior notice.

## How to start running; implementation

## Documentation

Essentially all Schönfinkel code constructs map directly to Haskell
counterparts. Schönfinkel does, however, define alternate syntax for many
constructs as well as several builtins. To do this, Schönfinkel defines a custom
code page that covers the same range as ASCII (1 byte per character), but with
non-printable ASCII characters (including TAB) replaced with custom symbols. For
the full codepage listed in an easy-to-read format, see "codepage.md".

### Custom syntax

#### Identifiers

One quirk of Schönfinkel is that all identifiers used by the programmer (i.e.,
are not pre-defined) must consist *solely* of lowercase letters optionally
followed by one or more single quotes (i.e., must match the regex `[a-z]+'*`).
The only exception to this rule is programmer-defined infix functions.
Characters in the range `[A-Z]` are reserved for builtins. Underscores (`_`)
have only one meaning in Schönfinkel, namely, empty patterns/throwaway
variables. Characters in the range `[0-9]` are reserved for numeric literals
exclusively.

Additionally, the first 5 lowercase letters as a single identifier (`a`, `b`,
`c`, `d`, `e`) are identifiers reserved for implicit input/command-line
arguments. `b`, `c`, `d`, and `e` are the 1st, 2nd, 3rd, and 4th inputs to the
program, in order, as `String`s. If less than 4 arguments are supplied, the
remaining variables are just the empty string (`""`). If more than 4 arguments
are supplied, `b`, `c`, `d`, and `e` are assigned normally, and `a` is always a
list of all arguments supplied (of type `[String]`), so all arguments are always
accessible.

Infix functions can still be defined normally like in Haskell. The characters
available to be used are slightly different: for one-character infix functions
defined by the programmer, the options are `!`, `?`, `#`, `&`, and `~`. Infix
functions with more characters (generally 2 at most) can combine those
characters as well as the following other characters: `$`, `<`, `>`, `^`, `:`
(so long as it doesn't start with `:`), `+`, `-`, `@`, `%`, `.`, `\`, and `*`.

#### Bindings

`let`/`where` bindings work similarly to Haskell, but have more concise syntax.
Variables are still bound using `=`, but instead of `let ... in ...` or
`... where ...`, Schönfinkel uses curly brackets (`{}`) and separates bindings
using commas (`,`). As an example, the following Schönfinkel code:

```
{x=3,y=1.5}x/y
```

...is identical to the following Haskell code:

```
let x = 3
    y = 1.5
in  x / y
```

Leftward-facing bindings (`<-`) in `do` blocks, guards, and list comprehensions
work identically as in Haskell, but use a single character (`←`) instead.

#### Conditionals

Schönfinkel uses shortened conditional notation for `if`/`else if`/`else`
constructs similar to the GHC extension "MultiWayIf", but without the `if`. To
avoid ambiguity, Schönfinkel uses a special character (`¦`) for the vertical
pipe character found in all list comprehensions (and additionally in `case`
expressions, as will be seen later). For example,

```
v=[(-1, 8), (-1, 3), (23, 1), (1, 1)]

[|i>j→-2|i<j→1|→0¦(i,j)←v]
```

yields the list `[1, 1, -2, 0]`. The equivalent Haskell is:

```
v=[(-1, 8), (-1, 3), (23, 1), (1, 1)]

[if i > j then -2 else if i < j then 1 else 0 | (i,j) <- v]
```

As you can see, omitting the condition (`|→`) always matches; it's the same as
matching on `True` (`|True->`), or, in Schönfinkel, `|𝐓→`.

It's common to get away with not using the `&&` function when logical AND is
needed. Instead, guards and multi-way "if"s like the one above can have multiple
conditions chained together using commas (`,`). For example, `|i>j,i>0→` is the
same as `|i>j&&i>0→`.

#### Ranges

Ranges work essentially the same as in Haskell, with one small change.
Descending ranges that don't use comma(s) work as expected in Schönfinkel. That
is,

```
[10..1]
```

is the same as the following Haskell:

```
[10,9..1]
```

#### Case expressions

Schönfinkel uses a shortened form of `case` expressions that otherwise work the
same way as their Haskell counterparts. The following Haskell:

```
f x =
    case x of
        0 -> 18
        1 -> 15
        2 -> 12
        _ -> 12 + x
```

can be translated directly into Schönfinkel as:

```
f x=⟨x¦0→18¦1→15¦2→12¦→12+x⟩
```

#### do notation

`do` notation works in Schönfinkel much the same way as in Haskell, but instead
of the word `do`, the `⟥` character is used instead. This saves the programmer
from having to write the `o` and the whitespace(s) after it. Additionally, as
mentioned before, monadic bindings use `←` instead of `<-`. Semicolons (`;`) can
be used to separate statements within a `do` block just like in Haskell.

### Built-in functions (builtins)

