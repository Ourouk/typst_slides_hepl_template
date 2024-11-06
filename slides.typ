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
    title: [Slides],
    subtitle: [A template for creating slides in HEPL],
    author: [Andrea Spelgatti],
    date: datetime.today(),
    institution: [HEPL],
  ),
)
#set heading(numbering: "1.")
#title-slide()
= Example slides
== Subsubject example
#lorem(45)
== Subsubject example 2
#lorem(60)
- #lorem(5)
- #lorem(5)
- #lorem(5)
- #lorem(5)
- #lorem(5)
== Subsubject example 3
#table(
  columns: (1fr,1fr),
  stroke: none,
  fill: (_, y) => if calc.even(y) { white.darken(10%) },
  inset: 8pt,
  table.header[#text(weight: "bold")[#lorem(2)]][#text(weight: "bold")[#lorem(2)]],
  [#lorem(5)],[#lorem(5)],
  [#lorem(5)],[#lorem(5)],
  [#lorem(5)],[#lorem(5)]
)
#footnote[Yes, we can do footnotes too!]
== Subsubject example 4
#definition("judgement")[
  #lorem(40)
]
#inf-rules(
  rule([$S(x) = S(y)$], [$x = y$], name: smallcaps[cong])
)
#box(inset: 10%)[
  #show math.equation: inf-style
  - $A type$    #h(1fr) $A$ is a (well-formed) type.
  - $Γ cx$      #h(1fr) $Γ$ is a (well-formed) context.
  - $a : A$     #h(1fr) $a$ is an object of type $A$.
  - $a ≡ b : A$ #h(1fr) $a$ and $b$ are definitionally equal objects of type $A$.
]