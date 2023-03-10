--- citefield.lua – an equivalent for citeproc of latex's citefield command
--- Use the syntax [@Citekey]{.field} to retrieve any valid CSL field (title, container-title, etc).
--- This filter *MUST* *RUN* *AFTER* Citeproc.
--- Copyright: © 2023 Albert Krewinkel & Bernardo Vasconcelos
--- License: MIT – see LICENSE for details

-- Makes sure users know if their pandoc version is too old for this
-- filter.
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

              the_link = pandoc.Link(the_result, "#ref-"..cite_id)

          end
          cite.content = {the_link}
          return cite
          -- return the_result
        end
      end
    end
  }
end

