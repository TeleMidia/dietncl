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
local table = table
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

         if s == 'media' then
            goto jump
         end

         for child in elt:children () do
            for i = 1, #listp do
               if listp[i] == child then
                  table.remove (listp, i)
               end
            end

            for i = 1, #listl do
               if listl[i] == child then
                  table.remove (listl, i)
               end
            end
         end

         ::jump::
         if #listp == 0 and #listl == 0  then
            xml.remove (elt:parent (), elt)
         end
      end
   end

   return (ncl)
end

return filter
