--- citefield.lua is citeproc alternative to latex's `\citefield`.
--- Use the syntax [@Citekey]{.csl_field} to retrieve any valid CSL field (full list available the README file).
--- For example, to retrieve the author's last name, use [@Citekey]{.author}.

--- ATTENTION: This filter *MUST* *RUN* *AFTER* Citeproc.

--- The original version of this script was generously contributed by Albert Krewinkel
--- at the [Pandoc-Dicuss mailing list](https://groups.google.com/g/pandoc-discuss/c/5gb64T4OU9Q). 

--- This version was modified by Bernardo Vasconcelos to include other options and improvements. 
--- It is being shared with permission (and at the request) of the original author for the benefit of Mr. Kite, there will be a show tonight, (...) no, just kidding, for the benefit of the community of Pandoc users.

--- Copyright: © 2023 - Albert Krewinkel & Bernardo Vasconcelos
--- License: MIT – see LICENSE for details

PANDOC_VERSION:must_be_at_least '2.17'

local stringify = require 'pandoc.utils'.stringify

function get_options(meta)
  if meta['link-citations'] then
      return {link_citations = meta['link-citations']}
  else
      return {}        
  end
end

csl_fields = {"abstract", "accessed", "annote", "archive", "archive_collection", "archive_location", "archive-place", "author", "authority", "available-date", "call-number", "chair", "chapter-number", "citation-key", "citation-label", "citation-number", "collection-editor", "collection-number", "collection-title", "compiler", "composer", "container-author", "container-title", "container-title-short", "contributor", "curator", "dimensions", "director", "division", "DOI", "edition", "editor", "editor-translator", "editorial-director", "event", "event-date", "event-place", "event-title", "executive-producer", "first-reference-note-number", "genre", "guest", "host", "illustrator", "interviewer", "ISBN", "ISSN", "issue", "issued", "jurisdiction", "keyword", "language", "license", "locator", "medium", "narrator", "note", "number", "number-of-pages", "number-of-volumes", "organizer", "original-author", "original-date", "original-publisher", "original-publisher-place", "original-title", "page", "page-first", "part-number", "part-title", "performer", "PMCID", "PMID", "printing-number", "producer", "publisher", "publisher-place", "recipient", "references", "reviewed-author", "reviewed-genre", "reviewed-title", "scale", "script-writer", "section", "series-creator", "source", "status", "submitted", "supplement-number", "title", "title-short", "translator", "URL", "version", "volume", "volume-title", "year-suffix"}


PANDOC_VERSION:must_be_at_least '2.17'

local stringify = require 'pandoc.utils'.stringify

local function has_value(tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return true
      end
  end
  return false
end

function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  doc.meta.bibliography = nil
  return doc:walk{
    Span = function (span)
      -- check that the span contains only a single cite object
      local cite = span.content[1]
      local citations = cite and cite.citations or nil
      if #span.content == 1 and cite.t == 'Cite' and #citations == 1 then
        the_arg = stringify(span.classes[1])
        if span.classes[2] then
          local extra_arg = stringify(span.classes[2])
        end
        -- dotted: to turn off linking
      if string.find(the_arg, ".", 1, true) then
        dotted = true
        the_arg = string.gsub(the_arg, "%.$", "")
        else
          dotted = false
      end

      -- print(the_arg)
      -- ordinal: to retrieve the first, second, third or forth author/editor/translator
      -- ordinal = 1
      if string.find(the_arg, "_first", 1, true) then
        ordinal = 1
        the_arg = string.gsub(the_arg, "%_first$", "")
        else if string.find(the_arg, "_second", 1, true) then
          ordinal = 2
          the_arg = string.gsub(the_arg, "%_second$", "")
          else if string.find(the_arg, "_third", 1, true) then
            ordinal = 3
            the_arg = string.gsub(the_arg, "%_third$", "")
            else if string.find(the_arg, "_forth", 1, true) then
              ordinal = 4
              the_arg = string.gsub(the_arg, "%_fourth$", "")
              else
                ordinal = 1
              end
            end
          end
      end


      -- Simple error trap
      if has_value(csl_fields, the_arg) then
        else
          return "#ERROR: Invalid CSL Field#"
      end
      -- print(citations[1].id)
      print(the_arg)
      local cite_id = citations[1].id
      local ref = doc.meta.references:find_if(
        function (r) return cite_id == r.id end
      )

      local the_result = ""
      local content = ref[the_arg]

      if content then
        -- replace the span with a specific citation field
          if the_arg == "author" or the_arg == "editor" or the_arg == "translator" then
            if content[ordinal] then
              if content[ordinal]["family"] then
                the_result = ref[the_arg][ordinal]["family"]
                else if ref[the_arg][ordinal]["literal"] then
                  the_result = ref[the_arg][ordinal]["literal"]
                else
                  the_result = "EMPTY"
                end
              end
            else -- Simple error trap
              print("ERROR: [".. cite_id .. "][" .. the_arg .. "][" .. ordinal .. "] is empty")
              return "#ERROR: [".. cite_id .. "][" .. the_arg .. "][" .. ordinal .. "] is empty#"
            end
          else if the_arg == "title" then
              the_result = pandoc.Emph{stringify(ref[the_arg])}
            else if the_arg == "title-short" then
                the_result = pandoc.Emph{stringify(ref[the_arg])}
              else
                the_result = stringify(ref[the_arg])
              end
            end
          end
        else -- return the span unchanged
          the_result = span
        end
        print (get_options(doc.meta).link_citations == false)
        -- print(the_result)
        if dotted == true
        or the_arg == "notes"
        or the_arg == "abstract"
        or the_arg == "keyword"
        or the_arg == "annote"
        or get_options(doc.meta).link_citations == false
        then
          return the_result
          else
            if get_options(doc.meta).link_citations == true then
              the_result = pandoc.Link(the_result, "#ref-"..cite_id)
              cite.content = {the_result}
              return cite
            else
              return the_result

            end
          end
        -- return the_result
      end
    end
  }
end

-- 2023-03-17-00-12
-- Added csl_field validation and new error msg: `#ERROR: Invalid CSL Field#`
-- Added dotted option to avoid creating a link and backref.
-- Added ordinal option to retrieve the first, second, third or forth author/editor/translator.
