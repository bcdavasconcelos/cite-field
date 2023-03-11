# Citefield for Pandoc Citeproc

[![GitHub build status][CI badge]][CI workflow]

[CI badge]: https://img.shields.io/github/actions/workflow/status/pandoc-ext/citefield/ci.yaml?logo=github&branch=main
[CI workflow]: https://github.com/pandoc-ext/citefield/actions/workflows/ci.yaml

## Background

[BibLaTeX](https://mirrors.ibiblio.org/CTAN/macros/latex/contrib/biblatex/doc/biblatex.pdf) has a command called *citefield* -- *e.g.* `\citefield{citekey}{field}` -- that allows printing the value of any field of a bibliographic entry. This Lua filter provides a similar functionality for [Citeproc](https://github.com/jgm/citeproc) using [Pandoc Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown) syntax: `[@Citekey]{.field}`.

## Syntax

The first argument is the `citekey`, the second argument is the CSL field / variable name. 

``` markdown
[@DA]{.author}, [@DA]{.title} <!-- One at a time -->
[@DA]{.publisher}
[@DA]{.page}
[@Trott2014]{.title}
[@Trott2014]{.issued}
[@Trott2014]{.URL}
[@DA; @Trott2014]{.title} <!-- ERROR: not allowed -->
```

Possible CSL variables include: 

```
abstract accessed annote archive archive_collection archive_location archive-place author authority available-date call-number chair chapter-number citation-key citation-label citation-number collection-editor collection-number collection-title compiler composer container-author container-title container-title-short contributor curator dimensions director division DOI edition editor editor-translator editorial-director event event-date event-place event-title executive-producer first-reference-note-number genre guest host illustrator interviewer ISBN ISSN issue issued jurisdiction keyword language license locator medium narrator note number number-of-pages number-of-volumes organizer original-author original-date original-publisher original-publisher-place original-title page page-first part-number part-title performer PMCID PMID printing-number producer publisher publisher-place recipient references reviewed-author reviewed-genre reviewed-title scale script-writer section series-creator source status submitted supplement-number title title-short translator URL version volume volume-title year-suffix
```

Most entries will contain only a small subset of these. If an invalid field is specified, or if the value of the field is empty, the filter will return an *empty string*. The filter modifies the internal document representation; it can be used with many publishing systems that are based on Pandoc.

### Plain Pandoc

Pass the filter to Pandoc via the `--lua-filter` (or `-L`) command
line option. **Please note that the filter must run AFTER Citeproc.**

    pandoc --citeproc --lua-filter citefield.lua ...

    pandoc -C --lua-filter citefield.lua ...

### Quarto

Users of Quarto can install this filter as an extension with

    quarto install extension bcdavasconcelos/citefield

and use it by adding `citefield` to the `filters` entry in their YAML header. As this filter must run AFTER, Citeproc will have to be called from an external filter to control the order of execution. For convenience, a `citeproc.lua` filter is already bundled with the extension.

``` yaml
---
filters:
  - citeproc
  - citefield
---
```

The content of `citeproc.lua` is the following:

```lua
function Pandoc (doc)
  return pandoc.utils.citeproc(doc)
end
```

### R Markdown

Use `pandoc_args` to invoke the filter. See the [R Markdown
Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/lua-filters.html)
for details.

``` yaml
---
output:
  word_document:
    pandoc_args: ['--lua-filter=citefield.lua']
---
```

### Compatibility with other Lua filters

The filter has been tested with [citation-backlinks](https://github.com/tarleb/citation-backlinks), that must run AFTER `citefield`.

``` yaml
---
filters:
  - citeproc
  - citefield
  - citation-backlinks
---
```

Other great filters likely to be compatible can be found at [Pandoc Extensions](https://github.com/pandoc-ext?type=source). 


License
------------------------------------------------------------------
Albert Krewinkel & contributors (see source file for more information)  
This Pandoc Lua filter is published under the MIT license, see 
file `LICENSE` for details.
