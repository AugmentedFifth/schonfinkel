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
(so long as it doesn't start with `:`), `+`, `-`, `@`, `%`, `.`, `\`, `=`, and
`*`.

#### Bindings

`let`/`where` bindings work similarly to Haskell, but have more concise syntax.
Variables are still bound using `=`, but instead of `let ... in ...` or
`... where ...`, Schönfinkel uses curly brackets (`{}`) and separates bindings
using commas (`,`). As an example, the following Schönfinkel code:

```haskell
{x=3,y=1.5}x/y
```

...is identical to the following Haskell code:

```haskell
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

```haskell
v=[(-1, 8), (-1, 3), (23, 1), (1, 1)]

[|i>j→-2|i<j→1|→0¦(i,j)←v]
```

yields the list `[1, 1, -2, 0]`. The equivalent Haskell is:

```haskell
v=[(-1, 8), (-1, 3), (23, 1), (1, 1)]

[if i > j then -2 else if i < j then 1 else 0 | (i, j) <- v]
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

```haskell
[9..1]
```

is the same as the following Haskell:

```haskell
[9,8..1]
```

#### Case expressions

Schönfinkel uses a shortened form of `case` expressions that otherwise work the
same way as their Haskell counterparts. The following Haskell:

```haskell
f x =
    case x of
        0 -> 18
        1 -> 15
        2 -> 12
        _ -> 12 + x
```

can be translated directly into Schönfinkel as:

```haskell
f x=⟨x¦0→18¦1→15¦2→12¦→12+x⟩
```

#### do notation

`do` notation works in Schönfinkel much the same way as in Haskell, but instead
of the word `do`, the `⟥` character is used instead. This saves the programmer
from having to write the `o` and the whitespace(s) after it. Additionally, as
mentioned before, monadic bindings use `←` instead of `<-`. Semicolons (`;`) can
be used to separate statements within a `do` block just like in Haskell.

### Built-in functions (builtins)

#### 1-byte built-in functions

`⊛`
===

Equivalent of `Control.Applicative.<*>` in Haskell.

Infix?: yes.

`≡`
===

Equivalent of `Data.Eq.==` in Haskell.

Infix?: yes.

`≢`
===

Equivalent of `Data.Eq./=` in Haskell.

Infix?: yes.

`¬`
===

Equivalent of `Data.Bool.not` in Haskell.

Infix?: no.

`⊙`
===

Equivalent of `Data.List.findIndices` in Haskell.

Infix?: yes.

`⩖`
===

Splits a list at every occurence of another given list of the same type.

Infix?: yes.

Haskell implementation of this function:

```haskell
import Data.List

infixl 9 ⩖
(⩖) :: Eq a => [a] -> [a] -> [[a]]
(⩖) l n =
    fst $ until (\(_, l') -> null l') (\(accu, rest) ->
        if genericTake needleLen rest == n then
            (accu ++ [[]], genericDrop needleLen rest)
        else
            (init accu ++ [last accu ++ [head rest]], tail rest)) ([[]], l)
    where needleLen = genericLength n
```

`⤔`
===

Equivalent of `Control.Monad.mapM` in Haskell.

Infix?: yes.

`∈`
===

Equivalent of `Data.Foldable.elem` in Haskell.

Infix?: yes.

`⁂`
===

Equivalent of `Control.Arrow.***` in Haskell.

Infix?: yes.

`⅋`
===

Equivalent of `Control.Arrow.&&&` in Haskell.

Infix?: yes.

`≫`
===

Equivalent of `Control.Monad.>>` in Haskell.

Infix?: yes.

`∩`
===

Equivalent of `Data.List.intersect` in Haskell.

Infix?: yes.

`∪`
===

Equivalent of `Data.List.union` in Haskell.

Infix?: yes.

`Σ`
===

Equivalent of `Data.Foldable.sum` in Haskell.

Infix?: no.

`↵`
===

Equivalent of `Control.Applicative.<$>` in Haskell.

Infix?: yes.

`⊢`
===

Equivalent of `Data.List.partition` in Haskell.

Infix?: yes.

`∀`
===

Equivalent of `Data.Foldable.all` in Haskell.

Infix?: yes.

`∃`
===

Equivalent of `Data.Foldable.any` in Haskell.

Infix?: yes.

`¡`
===

Equivalent of `Data.List.genericIndex` in Haskell.

Infix?: yes.

`Δ`
===

Equivalent of `Prelude.subtract` in Haskell.

Infix?: yes.

**N.B.:** The ASCII hyphen/minus sign (`-`) cannot be used for subtraction,
since it only serves to negate numbers (e.g. `-2.5`). Instead, this function
should be used.

`⌊`
===

Equivalent of `Prelude.floor` in Haskell.

Infix?: no.

`×`
===

Takes the cartesian product of two lists.

Infix?: yes.

Haskell implementation of this function:

```haskell
infixl 7 ×
(×) :: [a] -> [b] -> [(a, b)]
(×) xs ys = [(x, y) | x <- xs, y <- ys]
```

`⊠`
===

Equivalent of `Data.List.zip` in Haskell.

Infix?: yes.

`÷`
===

Equivalent of `Prelude.div` in Haskell.

Infix?: yes.

`$`
===

Unchanged from Haskell.

`%`
===

Equivalent of `Prelude.mod` in Haskell.

Infix?: yes.

`*`
===

Unchanged from Haskell.

`+`
===

Unchanged from Haskell.

`-`
===

Equivalent of `Prelude.negate` in Haskell.

Infix?: no.

`.`
===

Unchanged from Haskell.

`/`
===

Unchanged from Haskell.

`:`
===

Unchanged from Haskell.

`<`
===

Unchanged from Haskell.

`>`
===

Unchanged from Haskell.

`^`
===

Unchanged from Haskell.

`⋄`
===

Appends the right argument to the end of the left argument.

Infix?: yes.

Haskell implementation of this function:

```haskell
infixr 5 ⋄
(⋄) :: [a] -> a -> [a]
(⋄) l a = l ++ [a]
```

`A`
===

Equivalent of `Data.List.filter` in Haskell.

`B`
===

Equivalent of `Data.List.sortBy` in Haskell.

Mnemonic: sort**B**y

`C`
===

Equivalent of `Data.Foldable.concat` in Haskell.

Mnemonic: **C**oncat

`D`
===

Equivalent of `Data.List.nub` in Haskell.

Mnemonic: **D**istinct

`E`
===

Equivalent of `Data.Foldable.maximum` in Haskell.

Mnemonic: **E**xtremum

`F`
===

Equivalent of `Data.List.zipWith` in Haskell.

`G`
===

Equivalent of `Data.Foldable.minimum` in Haskell.

`H`
===

Equivalent of `Prelude.toEnum` in Haskell.

`I`
===

Equivalent of `Data.Foldable.null` in Haskell.

Mnemonic: un**I**nhabited

`J`
===

Equivalent of `Data.List.tail` in Haskell.

`K`
===

Equivalent of `Data.List.genericTake` in Haskell.

Mnemonic: ta**K**e

`L`
===

Equivalent of `Data.List.genericLength` in Haskell.

Mnemonic: **L**ength

`M`
===

Equivalent of `Prelude.show` in Haskell.

`N`
===

Equivalent of `Prelude.read` in Haskell.

`O`
===

Equivalent of `Prelude.fromEnum` in Haskell.

Mnemonic: **O**rd[inal]

`P`
===

Equivalent of `System.IO.print` in Haskell.

Mnemonic: **P**rint

`Q`
===

Replaces the given index of a list with a certain value. Does not change the
length of the list. Accepts negative indices, viz. an index of `-1` signifies
the last index of the list, `-2` signifies the second-to-last index, etc.

Haskell implementation of this function:

```haskell
import Data.List

Q :: Integral i => i -> a -> [a] -> [a]
Q i a (b:bs)
    | i < 0     = Q (genericLength bs + i + 1) a (b:bs)
    | i == 0    = a:bs
    | otherwise = b : Q (i - 1) a bs
```

`R`
===

Equivalent of `Data.List.reverse` in Haskell.

Mnemonic: **R**everse

`S`
===

Equivalent of `Data.List.sort` in Haskell.

Mnemonic: **S**ort

`T`
===

Equivalent of `Data.List.transpose` in Haskell.

Mnemonic: **T**ranspose

`U`
===

Equivalent of `Data.List.intercalate` in Haskell.

Mnemonic: **U**nwords/**U**nlines

`V`
===

Equivalent of `Data.List.scanl` in Haskell.

`W`
===

Equivalent of `Data.List.takeWhile` in Haskell.

Mnemonic: take**W**hile

`X`
===

Equivalent of `Data.Foldable.foldl'` in Haskell.

`Y`
===

Equivalent of `Data.Foldable.foldr` in Haskell.

`Z`
===

Equivalent of `Data.List.permutations` in Haskell.

#### 2-byte built-in functions

`≫=`
====

Equivalent of `Control.Monad.>>=` in Haskell.

Infix?: yes.

`≫>`
====

Equivalent of `Control.Arrow.>>>` in Haskell.

Infix?: yes.

`≫^`
====

Equivalent of `Control.Arrow.>>^` in Haskell.

Infix?: yes.

`≪<`
====

Equivalent of `Control.Arrow.<<<` in Haskell.

Infix?: yes.

`≪^`
====

Equivalent of `Control.Arrow.<<^` in Haskell.

Infix?: yes.

`⌊^`
====

Equivalent of `Prelude.ceiling` in Haskell.

Infix?: no.

`⌊#`
====

Equivalent of `Prelude.round` in Haskell.

Infix?: no.

`⌊!`
====

Equivalent of `Prelude.truncate` in Haskell.

Infix?: no.

`*>`
====

Equivalent of `Control.Applicative.*>` in Haskell.

Infix?: yes.

`**`
====

Unchanged from Haskell.

`++`
====

Unchanged from Haskell.
