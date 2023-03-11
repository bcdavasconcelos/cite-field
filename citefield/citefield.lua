--- citefield.lua is citeproc alternative to latex's `\citefield`.
--- Use the syntax [@Citekey]{.csl_field} to retrieve any valid CSL field (full list available the README file).
--- For example, to retrieve the author's last name, use [@Citekey]{.author}.

--- ATTENTION: This filter *MUST* *RUN* *AFTER* Citeproc.

--- The original version of this script was generously contributed by Albert Krewinkel
--- at the [Pandoc-Dicuss mailing list](https://groups.google.com/g/pandoc-discuss/c/5gb64T4OU9Q). 

--- This version was modified by Bernardo Vasconcelos to include some small improvements. 
--- It is being shared with permission (and at the request) of the original author for the benefit of Mr. Kite, there will be a show tonight, (...) no, just kidding, for the benefit of the community of Pandoc users.

--- Copyright: © 2023 - Albert Krewinkel & contributors
--- License: MIT – see LICENSE for details

PANDOC_VERSION:must_be_at_least '2.17'

local stringify = require 'pandoc.utils'.stringify

function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  doc.meta.bibliography = nil
  return doc:walk{
    Span = function (span)
      -- check that the span contains only a single cite object
      local cite = span.content[1]
      local the_link = ""
      local citations = cite and cite.citations or nil
      if #span.content == 1 and cite.t == 'Cite' and #citations == 1 then
        local cite_id = citations[1].id
        local ref = doc.meta.references:find_if(
          function (r) return cite_id == r.id end
        )
        local the_arg = stringify(span.classes[1])
        local the_result = ""
        if ref and the_arg then
          if ref[the_arg] then
          -- replace the span with a specific citation field
            if the_arg == "author" or the_arg == "editor" or the_arg == "translator" then
              if ref[the_arg][1]["family"] then
                the_result = ref[the_arg][1]["family"]
              else if ref[the_arg][1]["literal"] then
                the_result = ref[the_arg][1]["literal"]
              end
            end
            else if the_arg == "title" then
                the_result = pandoc.Emph{stringify(ref[the_arg])}
              else
                the_result = stringify(ref[the_arg])
              end
            end
          else
          -- return the span unchanged
          the_result = span
          end
          if the_arg == "notes"
          or the_arg == "abstract"
          or the_arg == "keyword"
          or the_arg == "annote"
          then
            the_link = the_result
          else
            the_link = pandoc.Link(the_result, "#ref-"..cite_id) -- TODO: use the value of `link-citations` metadata field to determine whether to add links
          end
          cite.content = {the_link}
          return cite
          -- return the_result
        end
      end
    end
  }
end

