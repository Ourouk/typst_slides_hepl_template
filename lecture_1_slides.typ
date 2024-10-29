#import "@preview/touying:0.5.3": *
#import "@preview/curryst:0.3.0" as curryst: rule

#import "theme.typ": *

#show: university-theme.with(
  config-colors(
    primary: primary-color,
    secondary: secondary-color,
    tertiary: tertiary-color,
    neutral-darkest: text-color
  ),
  config-info(
    title: [Modern Type Theory],
    subtitle: [An introduction to modern dependent type theory],
    author: [Ridan Vandenbergh],
    date: datetime.today(),
    institution: [KU Leuven],
  ),
)

#set heading(numbering: "1.")

#title-slide()

= Introduction

== Overview

Why study types?

- to introduce *rigorous correctness* to programming languages
- to understand the core theory in *proof assistants* like Agda, Coq, ...
- to formalize a *new set of foundations* for mathematics #footnote([As an alternative to ZFC set theory])
- to draw commutative diagrams you can be proud of

#large-center-text(emoji.construction)

What we'll discuss in this course:

- The design of a good type theory
- Logic as an *emergent property*
- Martin-Löf (extensional) type theory
- Concepts from category theory presented in type theory

#large-center-text(emoji.construction)

== Set theory vs type theory

As we present type theory as a suitable replacement for set theory as a foundation of mathematics, it's worth nothing the differences:

#table(
  columns: (1fr,1fr),
  stroke: none,
  fill: (_, y) => if calc.even(y) { white.darken(10%) },
  inset: 8pt,
  table.header[#text(weight: "bold")[Set theory]][#text(weight: "bold")[Type theory]],
  [Comprised of two layers: #box[First-order] logic with axioms for the theory on top],[Is its own deductive system: no dependency on logic],
  [Two basic notions: sets and propositions],[One basic notion: _types_],
  [One deductive outcome#footnote[We'll start calling these _judgements_ soon]: $A$ has a proof.],[Several deductive outcomes: introducing types, variables, ...]
)

= Foundations

== Deductive system

=== Judgements

One word we'll come across often is *judgement*:

#definition("judgement")[
  A judgement is the _assertion_ or _validation_ of some *proposition* $P$, hence the claim of a *proof* of $P$.
]

To distinguish a proposition from a judgement, the turnstile symbol is used:

#place(right)[#set text(black.lighten(40%));  _I know $P$ is true._]
$
⊢ P
$

If our "proof" of $P$ is based on assumptions, we write those in front of the ⊢ :
#place(right)[#set text(black.lighten(40%));  _From $A$, I know that $P$._]
$
A ⊢ P
$

Judgements form a core building block of our type theory.


As seen in the introduction, type theory is its own deductive system.
Let's define that:

#definition("deductive system")[
  A deductive system (or, sometimes, *inference system*) is specified by
  + A collection of allowed *judgements*, and
  + A collection of _steps_, each of which has a (typically finite) list of judgments as hypotheses and a single judgment as conclusion.
    A step is usually written as \
    #inf-rules(inset: 0%, rule($J$, $J_1$, [...], $J_n$)) \
    If $n "is" 0$, the step is often called an *axiom*.
]

---

The steps of a deductive system are generated by *inference rules*, which are schematic ways of describing collections of steps, generally involving metavariables.

For example, consider the following inference rule, describing a simple congruence:

#inf-rules(
  rule([$S(x) = S(y)$], [$x = y$], name: smallcaps[cong])
)

Here, $x$ and $y$ are variables.
Substituting particular terms for them will yield a _step_ which is an instance of this inference rule.

---

In type theory, every element _by its very nature_ is an element of some type.
Introducing a variable, therefore, requires specifying its type.

We will be using the following judgements:

#box(inset: 10%)[
  #show math.equation: inf-style
  - $A type$    #h(1fr) $A$ is a (well-formed) type.
  - $Γ cx$      #h(1fr) $Γ$ is a (well-formed) context.
  - $a : A$     #h(1fr) $a$ is an object of type $A$.
  - $a ≡ b : A$ #h(1fr) $a$ and $b$ are definitionally equal objects of type $A$.
]

Not every presentation of type theory will brandish the same set of judgements. \
In particular, the canonical version of homotopy type theory as presented by _the_ HoTT book, only includes 2 judgements (the third and fourth)!

== What's in a type?

Types may _look like_ sets, but they are not!

In type theory, a type:
- is a first-class mathematical object
- types may or may not have *inhabitants* (values of that type)
- types are not iterable, quantifiable over or have cardinality

We'll formalize how to define a set of *base types*, \
and how we *construct* types from other types, \
forming a simple process to create types by *induction*.

---

There is a general pattern for introduction of a new kind of type.
We specify:

- *formation rules* for the type: for example, we can form the \ function type $A -> B$ when $A$ is a type and when $B$ is a type.
- *constructors* for its elements: for example, a function type has one constructor, #box[$λ$-abstraction].
- *eliminators*: How to use the type's elements, for example function application.
- a *computation rule*#footnote[also referred to as $beta$-reduction or $beta$-equivalence], which expresses how an eliminator acts on a constructor.

- an optional *uniqueness principle*#footnote[also referred to as $eta$-expansion. When the uniqueness principle is not taken as a rule of judgemental equality, it is often nevertheless provable as a _propositional_ equality.], which expresses uniqueness of maps into or out of that type.

---

#definition("type")[
  A type is a first-class mathematical object defined by a set of *formation rules*, *constructors*, *eliminators*, *computation rules* and an optional *uniqueness principle*.
]

A type#footnote[In type theory. Types in #stlc, for example, behave differently.] is nothing more and nothing less than the behaviour as described by its rules.

= Simply typed lambda calculus

== Terms in #stlc

The theory of functional programming is built on extensions of a core language known as the _simply-typed lambda calculus_ (henceforth abbreviated #stlc).

#stlc is composed of two kinds of _sorts_: *types* and *terms*.

We can define types in this calculus as expressions generated by the grammar

$ "Types" A,B := bold(b) | A times B | A -> B. $

Note the included $bold(b)$ type: without it the grammar would have no terminal symbols.

Equivalently, the #inf-style[$A type$] judgement may be derived from a number of inference rules corresponding to the production rules of $"Types"$:

#inf-rules(
  rule([$bold(b) type$]),
  rule([$A times B type$], [$A type$], [$B type$]),
  rule([$A -> B type$], [$A type$], [$B type$]),
)

See how each rule derives *a new judgement* from a number of other judgements.

---

Remember that an inference rule is a form of a generic step, with metavariables we must fill in.

By combining these rules into a tree of steps whose leaves have no premises, we can produce _derivations_ of judgements.

#[
  The tree below is a proof that
  #show "b": $bold(b)$
  #inf-style[$(b times b) -> b$] is a type:

  #let btype = rule([$b type$])
  #inf-rules(
    rule(
      [$(b times b) -> b type$],
      rule(
        [$b times b type$],
        btype, btype
      ),
      btype
    )
  )
]

It is imperative to remember and learn to identify the metavariables in inference rules, as we'll be using them very often.

---

Terms are however, considerably more difficult to define due to two issues:
- There are infinitely many sorts of terms (one for each type)
- *#set text(black); The body #underline[b] of a function $λ x. underline(b) : A -> B$ is a term of type $B$ of our grammar _extended_ by a new constant $x: A$*!

To account for these extensions, we will introduce the concept of a *context* first.

---

=== Context

#v(-1em) // to make the last sentence fit
#definition("context")[
The judgement #inf-style[$⊢ Γ cx$] ("$Γ$ is a context") expresses that $Γ$ is a list of pairs of term variables ($x$, $y$, ...) with types ($A$, $B$, ...).
]

We write $bold(1)$ for the empty context and $Γ, x:A$ for the extension of $Γ$ by a variable $x$ with type $A$.

The #inf-style[$⊢ Γ cx$] judgement may be derived from the following inference rules:

#inf-rules(
  inset: 20%,
  rule([$⊢ bold(1) cx$]),
  rule([$⊢ Γ\,x:A cx$], [$⊢ Γ cx$], [$A type$], name: smallcaps[cx-ext]),
)

A context $Γ$ expresses the "parameter space" types have access to, enabling us to specify the variables that a dependent type depends on.

== Terms and computation

Now, defining terms becomes relatively straightforward, encompassing a number of rules:

#inf-rules(
  rule($Γ ⊢ x : A$, $(x:A) in Γ$, $Γ cx$),
  rule($Γ ⊢ mono(c) : bold(b)$, $"a base term" mono(c)$, $Γ cx$),
  rule($Γ ⊢ (a,b): A times B$, $Γ ⊢ a : A$, $Γ ⊢ b : B$),
  rule($Γ ⊢ fst(p) : A$, $Γ ⊢ p : A times B$),
  rule($Γ ⊢ snd(p) : B$, $Γ ⊢ p : A times B$),
  rule($Γ ⊢ λ x.b : A -> B$, $Γ,x:A ⊢ b : B$),
  rule($Γ ⊢ f" "a : B$, $Γ ⊢ a : A$, $Γ ⊢ f : A -> B$),
)

#inf-style[$Γ ⊢ x:A$] is read "$x$ has type $A$ in context $Γ$."

Note that these contain the construction and elimination rules for all types in #stlc.

---

Finally, we must not forget the computation rules, which introduce a notion of sameness to our theory:

#inf-rules(
  inset: 5%,
  rule($Γ ⊢ fst((a,b)) ≡ a : A$, $Γ ⊢ a : A$, $Γ ⊢ b : B$),
  rule($Γ ⊢ snd((a,b)) ≡ b : B$, $Γ ⊢ a : A$, $Γ ⊢ b : B$),
  rule($Γ ⊢ p ≡ (fst(p), snd(p)) : A times B$, $Γ ⊢ p : A times B$),
  rule($Γ ⊢ (λ x.b) ≡ b[a\/x]:B$, $Γ,x:A ⊢ b:B$, $Γ ⊢ a:A$),
  rule($Γ ⊢ f ≡ λ x.(f" "x):A->B$, $Γ ⊢ f : A->B$)
)

The substitution operator $Phi[x\/y]$ means replacing every occurrence of $y$ with $x$ in $Phi$.
For a definition, refer to the book.

// TODO: this shouldn't be a subsec..
// == Exercise <touying:hidden>
// 
// Attempt to derive that $λ x. ()$ is a term.
// 
// #large-center-text[#todo()]

= Towards dependent type theory

== Types and contexts

Just as we did with the judgement for terms, we will continue by extending the type judgement using contexts:

#inf-style[$A type$] becomes #inf-style[$Γ ⊢ A type$] read "$A$ is a type in context $Γ$."

This has many downstream implications: we must now take into account _in what context_ a type is well-formed. A handful of rules must be updated, starting with the #inf-style[cx] judgement:

#inf-rules(
  rule([$⊢ Γ\,x:A cx$], [$⊢ Γ cx$], [$Γ ⊢ A type$], name: smallcaps[cx-ext']),
)

For the rest, you are invited to update those in your head.

---

Armed with term variable context added to the type judgment, we can now explain when $(x : A) -> B$ is a well-formed type:

#inf-rules(
  rule([$Γ ⊢ (x : A) -> B type$], [$Γ ⊢ A type$], [$Γ,x:A ⊢ B type$])
)

This is an example of a *formation rule*.

== Type and term dependency

We can categorize type systems into three 'tiers' of dependency:

- It may be *not dependent*, disallowing a type to be parameterized by another type. For example, C's type system is not dependent.
- It may have *uniform dependency*: types and terms may be parameterized by _other types_. Generic types in Java are an example of uniformly parameterized types.
- Or, ultimately, a type system exhibits *full-spectrum dependency* when types are indexed by terms.

---

=== Full-spectrum dependency

To achieve full-spectrum dependency, a type system must allow types to depend on other types and values, such as the following type family indexed by #inf-style[$"Nat"$]:

#align(center)[
  ```agda
  nary : Set → Nat → Set
  nary 𝐴 0 = 𝐴
  nary 𝐴 (suc 𝑛) = 𝐴 → nary 𝐴 𝑛
  ```
]

`nary` takes a type $A$, some number #inf-style[$n : "Nat"$] and produces a function of the shape:
$ underbrace(A -> ..., n "times") -> A $

Evidently, the _structure_ of the resulting type is based on the input $n$. \
This is a feat only a type system with full-spectrum dependency supports.

== Substitution calculus

#[
  #set text(0.99em)

  Let us turn our attention to what is called the *variable rule*:

  #inf-rules(
    rule([$Γ, x : A ⊢ x : A$], name: smallcaps[var])
  )

  Although this looks sensible, this rule's assumptions do not hold:
  - #underline[Assumption 1]: #inf-style[$⊢ (Γ, x:A) cx$]
    - We could add #inf-style[$⊢ Γ cx$] and #inf-style[$Γ ⊢ A type$] to the premise for this to hold, but ..
  - #underline[Assumption 2]: #inf-style[$Γ,x:A ⊢ A type$]
    - .. even then, #inf-style[$Γ ⊢ A type$] does not imply #inf-style[$Γ, x:A ⊢ A type$]! \
      This would require us to prove a _weakening lemma_ for types, which is not trivial.

  Instead of that approach, or adding a silent weakening rule#footnote[#inf-style[$Γ,x:A⊢B type$ when $Γ⊢B type$], but this introduces ambiguity into our rules.], we will opt to introduce *explicit weakening*.
]

---

The *explicit weakening rule* asserts the existence of an operation sending types and terms in context $Γ$ to types and terms in context $Γ,x:A$, both written #inf-style[$-"[p]"$]#footnote[The p stands for projection. We'll see why later.].

#inf-rules(
  rule($Γ,x:A⊢B"[p]" type$, $Γ⊢B type$, $Γ⊢A type$),
  rule($Γ,x:A⊢b"[p]":B"[p]"$, $Γ⊢b:B$, $Γ⊢A type$)
)

Using these rules, we can fix the variable rule from before:

#inf-rules(
  rule($Γ,x:A⊢x:A"[p]"$, $⊢Γ cx$, $Γ⊢A type$, name: smallcaps[var])
)

Bringing us to a safe and unambiguous variable rule.

---

To use variables that occur earlier in the context, we can apply weakening repeatedly until they are the last variable.

#[
  #show math.equation: inf-style
  Suppose we want to use $x$ in the context $(x:A,y:B)$:
  #place(left)[We know that]
  #place(right)[#set text(black.lighten(40%));  _Apply variable rule_]
  #align(center)[$x:A⊢x:A"[p]"$]

  #place(left)[And so]
  #place(right)[#set text(black.lighten(40%));  _Apply weakening_]
  #align(center)[$x:A,y:B⊢x"[p]":A"[p]""[p]".$]

  In general, we can derive the following principle:

  #let princ = inf-rules(
    inset: 0%,
    rule(
      $Γ,x:A,y_1:B_1,...,y_n:B_n⊢x underbrace("[p]"..."[p]", n "times") : A underbrace("[p]"..."[p]", n+1 "times")$,
      $Γ⊢A type$,
      $Γ,x:A⊢B_1 type$,
      $...$,
      $Γ,x:A,y_1:B_1,...⊢B_n type$
    )
  )
  #princ

  ---

  #princ

  #v(.5em) // the underbraces hug the text just a bit too closely without this

  As "happy accident" of this approach we find is that the term $x"[p]"^n$ encodes in two ways which variable it refers to:
  - by the name $x$,
  - but also by the number of weakenings $n$ (called the variable's *de Bruijn index*),

  so we might as well drop variable names altogether!

  From now on, we can present contexts as lists of types $A.B.C$ with no variable names, and adopt a single notation for "the last variable in the context".#footnote[Freeing us from the torment of explaining variable binding.]

]

---

#definition("simultaneous substitution")[
  A simultaneous substitution (henceforth, just *substitution*) is an arbitrary composition of
  - zero or more *weakenings*
  - zero or more *term substitutions*
  A substitution can turn any context $Γ$ into any other context $Δ$.
]


Rather than axiomatizing _single_ term substitutions and weakenings, we will axiomatize the concept of a simultaneous substitution instead.

---

For this, we will add one final basic judgement to our theory:

#inf-rules( // abuse :)
  inset: 20%,
  $Δ⊢γ:Γ$,
  ["$γ$ is a substitution from $Δ$ to $Γ$"]
)

corresponding to operations that send types/terms from context $Γ$ to context $Δ$#footnote[If this notation seems backward to you, you must learn to live with it.].

#underline[Notation]
#[
  #show math.equation: inf-style
  We write
  - $Cx$ for the set of contexts,
  - $Sb(Δ, Γ)$ for the set of substitutions from $Δ$ to $Γ$,
  - $Ty(Γ)$ for the set of types in context $Γ$,
  - and $Tm(Γ, A)$ for the set of terms of type $A$ in context $Γ$. 
]

= Martin-Löf type theory

== <touying:hidden> // FIXME: needed to get the content not to display on the title slide

Now we _finally_ have everything we need to discuss the dependent type theory as described by Martin-Löf:

The rules for contexts are as previous, but without variable names:

#inf-rules(
  inset: 20%,
  rule($⊢ bold(1) cx$),
  rule($⊢Γ.A cx$, $⊢Γ cx$, $Γ⊢A type$, name: smallcaps[cx-ext])
)

The purpose of a substitution $Δ⊢𝛾:Γ$ is to shift types and terms from context $Γ$ to context $Δ$:

#inf-rules(
  rule($Δ⊢A[γ] type$, $Δ⊢γ:Γ$, $Γ⊢A type$),
  rule($Δ⊢α[γ]:A[γ]$, $Δ⊢γ:Γ$, $Γ⊢α:A$)
)

---

The simplest interesting substitution is weakening, written $fat(p)$:

#inf-rules(
  rule($Γ.A⊢fat(p):Γ$, $Γ⊢A type$)
)

In concert with the substitution rules and $fat(p)$, we can recover the weakening rule seen previously.
Further, we have rules that close substitutions under nullary and binary composition:

#inf-rules(
  rule($Γ⊢id:Γ$, $⊢Γ cx$),
  rule($Γ_2⊢γ_0 compose γ_1 : Γ_0$, $Γ_2⊢γ_1:Γ_1$, $Γ_1⊢γ_0:Γ_0$)
)

---

And these operations are unital and associative, as one might expect:

#inf-rules(
  inset: 0%,
  rule($Δ⊢γ compose id = id compose γ = γ : Γ$, $Δ⊢γ:Γ$),
  rule($Γ_3⊢γ_0 compose (γ_1 compose γ_2) = (γ_0 compose γ_1) compose γ_2 : Γ_0$, $Γ_3 ⊢ γ_2 : Γ_2$, $Γ_2⊢γ_1:Γ_1$, $Γ_1⊢γ_0:Γ_0$)
)#footnote[Yes, composition is reversed just like the $Δ⊢γ:Γ$ syntax.]

#todo(content: [TODO: put a[id]=a and substitution of composition is composition of substitution here?])

---

As we've done away with variable names, we update the variable rule as follows:

#inf-rules(
  rule($Γ.A⊢ fat(q):A"[p]"$, $Γ⊢A type$, name: smallcaps[var])
)

We will use $fat(q)$ to unambiguously refer to the last variable in the context. A variable in our system is a term of the form $fat(q)[fat(p)^n]$, where $n$ is its de Bruijn index.

#todo(content: [TODO: terminal substitutions and substitution extension])
