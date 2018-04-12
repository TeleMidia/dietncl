--[[ filter.prenorm1 -- First pre-normalization step.
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

local filter = {}

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')

local ipairs = ipairs

_ENV = nil

---
-- Guarantees that each connector is referenced by exactly one link.
--
-- Dependencies: `dietncl.filter.import`
-- @module dietncl.filter.prenorm1
---

---
-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM1, implements the first pre-normalization
-- step: It guarantees that each connector is referenced by exactly one
-- link.
-- @param ncl NCL document (root element).
-- @return the modified NCL document (root element).
---
function filter.apply (ncl)
   for conn in ncl:gmatch ('causalConnector') do
      local list = {ncl:match ('link', 'xconnector', conn.id)}

      if #list == 0 then
         xml.remove (conn:parent (), conn)
         goto continue
      end

      if #list == 1 then
         goto continue          -- nothing to do
      end

      for _,link in ipairs (list) do
         if link == list[#list] then
            goto continue
         end

         local parent = conn:parent ()
         local dup = conn:clone ()

         dup.id = aux.gen_id (ncl)
         link.xconnector = dup.id
         parent:insert (dup)
      end
      ::continue::
   end
   return ncl
end

return filter
