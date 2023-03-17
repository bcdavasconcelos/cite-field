---
title: Lorem ipsum
author: Nullus
mainfont: Alegreya
citeproc: false
filters:
  - citeproc.lua
  - citefield.lua
---

# *Cite field*


Syntax: `[@Citekey]{.csl_field}`  


author: [@Trott2014]{.author}  
title: [@Trott2014]{.title}  

author: [@DA]{.author}  
abbreviation: [@DA]{.title-short}  
title: [@DA]{.title}  
origtitle: [@DA]{.original-title}  

## *Cite field* with no link

Syntax: `[@Citekey]{.csl_field.}`  
*Add extra dot at the end of the field name.*  

author: [@Trott2014]{.author.}  
title: [@Trott2014]{.title.}  

## *Cite field* with index

Syntax: `[@Citekey]{.editor_first}` |  `[@Citekey]{.editor_second}` | `[@Citekey]{.editor_third}`

editor 1: [@ENSusemihlApelt1903]{.editor_first}  
editor 2: [@ENSusemihlApelt1903]{.editor_second}  

editor 1: [@ENSusemihlApelt1903]{.editor_first.}  
editor 2: [@ENSusemihlApelt1903]{.editor_second.}  


## Error trapping

Invalid field: [@ENSusemihlApelt1903]{.nonexistent}  
Empty field: [@ENSusemihlApelt1903]{.editor_third}  


# Bibliography

---
references:
- author:
  - family: Trott
    given: Adriel M.
  id: Trott2014
  issued: 2014
  page: xiii-239
  publisher: CUP
  title: Aristotle on the nature of community
  type: book
  url: "www.google.com"
- author:
  - family: Aristotle
  call-number: "0086.002"
  container-title: Aristotelis opera
  editor:
  - family: Bekker
    given: Immanuel
  id: DA
  issued: 1831
  keyword: primary sources, ancient philosophy, ancient greek
  original-title: Περὶ ψυχῆς
  page: 402a01-435b25
  publisher: Reimer
  publisher-place: Berlim
  title: De anima
  title-short: DA
  type: chapter
  url: "www.google.com"
  notes: |
    On the Soul (Greek: Περὶ Ψυχῆς, Peri Psychēs; Latin: De Anima) is a major treatise written by Aristotle c. 350 BC. His discussion centres on the kinds of souls possessed by different kinds of living things, distinguished by their different operations. Thus plants have the capacity for nourishment and reproduction, the minimum that must be possessed by any kind of living organism. Lower animals have, in addition, the powers of sense-perception and self-motion (action). Humans have all these as well as intellect.
- author:
  - family: Aristotelis
  call-number: 0086.010
  editor:
  - family: Susemihl
    given: Franz
  - family: Apelt
    given: Otto
  id: ENSusemihlApelt1903
  issued: 1903
  publisher: Teubner
  publisher-place: Leipzig
  title: Ethica nicomachea
  type: book
---
