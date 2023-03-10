--- citefield.lua – an equivalent for citeproc of latex's citefield command
--- Copyright: © 2023 Albert Krewinkel & Bernardo Vasconcelos
--- License: MIT – see LICENSE for details

-- Makes sure users know if their pandoc version is too old for this
-- filter.
PANDOC_VERSION:must_be_at_least '2.17'

stringify = require 'pandoc.utils'.stringify
local cites = {}
-- counter for cite identifiers
local cite_number = 1


local function with_latex_label(s, el)
  if FORMAT == "latex" then
    return {pandoc.RawInline("latex", "\\label{" .. s .. "}"), el}
  else
    return {el}
  end
end

function append_inline(blocks, inlines)
  local last = blocks[#blocks]
  if last.t == 'Para' or last.t == 'Plain' then
    -- append to last block
    last.content:extend(inlines)
  else
    -- append as additional block
    blocks[#blocks + 1] = pandoc.Plain(inlines)
  end
  return blocks
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
        local ref_id = citations[1].id
        
        local cite_id = "cite_" .. cite_number
        cite_number = cite_number + 1
        if cites[ref_id] then
          table.insert(cites[ref_id], cite_id)
        else
          cites[ref_id] = {cite_id}
        end
        local ref = doc.meta.references:find_if(
          function (r) return ref_id == r.id end
        )
        local the_arg = stringify(span.classes[1])
        local the_result = ""
        if ref and the_arg then
          if ref[the_arg] then
          -- replace the span with a specific citation field
            if the_arg == "author" or the_arg == "editor" or the_arg == "translator" then
              the_result = stringify(ref[the_arg][1]["family"])
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
          
          return pandoc.Span(
            pandoc.Span(
              pandoc.Link(
                with_latex_label(
                  cite_id, the_result
                ), 
                "#ref-"..ref_id, 
                "", 
                {
                  role = "doc-biblioref"
                }
              ),
              {
                class = "citation", 
                cites = ref_id}
              ), 
              pandoc.Attr(
                cite_id
              )
            )
          -- return the_result
        end
      end
    end,
    Div = function (el)
      local citation_id = el.identifier:match("ref%-(.+)")
      
      local return_link = pandoc.RawInline("latex", "\\Acrobatmenu{GoBack}{$\\hookleftarrow$}")
      if citation_id then
        local backlinks = pandoc.Inlines{pandoc.Space(), pandoc.Str("[")}
      
        if FORMAT == "latex" then
          table.insert(backlinks, return_link)
        end
    
        for i,cite_id in ipairs(cites[citation_id] or {}) do
          local marker = pandoc.Str(i)
    
          if FORMAT == "latex" then
            marker = pandoc.RawInline("latex", "\\pageref{" .. cite_id .. "}")
          end
          if #backlinks > 2 then
            table.insert(backlinks, pandoc.Str(","))
            table.insert(backlinks, pandoc.Space())
          end
          table.insert(backlinks, pandoc.Link(marker, "#"..cite_id))
        end
        if #backlinks > 2 then
          append_inline(el.content, backlinks .. {pandoc.Str("]")})
    
    --      append_inline(el.content, {pandoc.Space()} .. backlinks .. {pandoc.Str("]")})
        end
        return el
      end
    end
    
  }
end
