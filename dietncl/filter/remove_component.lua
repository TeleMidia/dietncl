--[[ filter.unused_media -- Remove unused medias.
     Copyright (C) 2013-2017 PUC-Rio/Laboratorio TeleMidia

This file is part of DietNCL.

DietNCL is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your
option) any later version.

DietNCL is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with DietNCL.  If not, see <http://www.gnu.org/licenses/>.  ]]--

local print = print
local ipairs = ipairs
local filter = {}
local xml = require ('dietncl.xmlsugar')
_ENV = nil

---
-- Removes all `<media>` and `<context>` elements that are not being
-- referenced from NCL document.
--
-- @module dietncl.filter.remove_component
---

---
-- The REMOVE COMPONENT filter removes all media and context elements that
-- are not being referenced by link or port from a given NCL document.
-- @param ncl NCL document (root element).
-- @return the modified NCL document (root element).
---
function filter.apply (ncl)
   for _,s in ipairs {'media', 'context'} do
      for elt in ncl:gmatch (s) do
         local listl = {ncl:match ('bind', 'component', elt.id)}
         local listp = {ncl:match ('port', 'component', elt.id)}

         for _,c in elt:children() do
            local listlc = {ncl:match ('bind', 'component', c.id)}
            local listpc = {ncl:match ('port', 'component', c.id)}

            if #listpc == 0 and #listlc == 0  then
               xml.remove (c:parent (), c)
            end

            goto out
         end

         if #listp == 0 and #listl == 0  then
            xml.remove (elt:parent (), elt)
         end

         ::out::
      end
   end

   print (ncl)
   return (ncl)
end


return filter
