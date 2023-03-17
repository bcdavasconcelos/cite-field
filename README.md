# Citefield for Pandoc Citeproc

<!-- [![GitHub build status][CI badge]][CI workflow] -->

<!-- [CI badge]: https://img.shields.io/github/actions/workflow/status/pandoc-ext/citefield/ci.yaml?logo=github&branch=main
[CI workflow]: https://github.com/pandoc-ext/citefield/actions/workflows/ci.yaml -->

## Motivation

[BibLaTeX](https://mirrors.ibiblio.org/CTAN/macros/latex/contrib/biblatex/doc/biblatex.pdf) has a command called *citefield* -- *e.g.* `\citefield{citekey}{field}` -- that allows printing the value of any field of a bibliographic entry. 

This Lua filter provides a similar functionality for [Citeproc](https://github.com/jgm/citeproc) using [Pandoc Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown) syntax.

## Basics

The first argument is the `citekey`, the second argument is the CSL field / variable name. 

- `[@DA]{.title}` will return the title of the reference with the citekey `DA`.

### Links

If the global option `link-citations` is set to `true` (default), all citations processed by the filter will link to the bibliography. 

You can turn this off by either globally disabling links with `link-citations: false` or disabling it only for the citations processed by the filter, with `link-fields: false`.

Alternatively, you can diable the creation of links in *ad hoc* fashion, for a specific citation, by adding a dot at the end of the field name.

- `[@DA]{.author.}`
- `[@DA]{.title.}`

### Names

Fields with names, such as `author`, `editor` and `translator` will return the family name of the `first` author/editor or translator by default. 

You can change this by adding `_first`, `_second`, `_third` or `_forth` to the csl_field name. 

- `[@ENSusemihlApelt1903]{.editor_first}` will return the family name of the first editor.  
- `[@ENSusemihlApelt1903]{.editor_second}` will return the family name of the second editor.  

You can use both options in tandem:

- `[@ENSusemihlApelt1903]{.editor_second.}` will return the family name of the second editor without creating a link.  



### Multiple Citations

Use one `citation` at a time and a single `csl_field` name.

**NOT** allowed: ~~`[@DA]{.author .title}`~~   
Alternative: `[@DA]{.author} [@DA]{.title}`  


**NOT** allowed: ~~`[@DA; @Trott2014]{.title}`~~  
Alternative: `[@DA]{.title} [@Trott2014]{.title}` 
  

### CSL Fields

Possible CSL variables include: 

```
abstract accessed annote archive archive_collection archive_location archive-place author authority available-date call-number chair chapter-number citation-key citation-label citation-number collection-editor collection-number collection-title compiler composer container-author container-title container-title-short contributor curator dimensions director division DOI edition editor editor-translator editorial-director event event-date event-place event-title executive-producer first-reference-note-number genre guest host illustrator interviewer ISBN ISSN issue issued jurisdiction keyword language license locator medium narrator note notes number number-of-pages number-of-volumes organizer original-author original-date original-publisher original-publisher-place original-title page page-first part-number part-title performer PMCID PMID printing-number producer publisher publisher-place recipient references reviewed-author reviewed-genre reviewed-title scale script-writer section series-creator source status submitted supplement-number title title-short translator URL version volume volume-title year-suffix
```

Most entries will contain only a small subset of these. If an invalid field is specified, or if the value of the field is empty, the filter will return an error message. 

The filter modifies the internal document representation; it can be used with many publishing systems that are based on Pandoc.

## Usage

### Plain Pandoc

Pass the filter to Pandoc via the `--lua-filter` (or `-L`) command
line option. 

**Please note that the filter must run AFTER Citeproc.**


    pandoc --citeproc --lua-filter citefield.lua ...

    pandoc -C --lua-filter citefield.lua ...

### Quarto

Users of Quarto can install this filter as an extension with

    quarto install extension bcdavasconcelos/citefield

and use it by adding `citefield` to the `filters` entry in their YAML header. For convenience, a `citeproc.lua` filter is already bundled with the extension as the `citefield` filter must run after *Citeproc* (which is currently not possible in Quarto without this work-around).

``` yaml
---
filters:
  - citefield
---
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
  - citefield
  - citation-backlinks
---
```

Other great filters likely to be compatible can be found at [Pandoc Extensions](https://github.com/pandoc-ext?type=source). 

License
------------------------------------------------------------------
Albert Krewinkel & Bernardo CDA Vasconcelos  
This Pandoc Lua filter is published under the MIT license, see 
file `LICENSE` for details.

The original version of this script was generously contributed by [Albert Krewinkel](https://github.com/tarleb) to the [Pandoc-Dicuss mailing list](https://groups.google.com/g/pandoc-discuss/c/5gb64T4OU9Q). It is being shared with permission (and at the request) of the original author for the benefit of the community of Pandoc users.

The current version was modified by Bernardo CDA Vasconcelos to include error msgs, csl-field validation, making all field retrievable (including items in lists), and adding emph for titles. 

