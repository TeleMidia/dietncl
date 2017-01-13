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
-- Removes all `<descriptor>` elements from NCL document.
--
-- @module dietncl.filter.descriptor
---

---
-- Avoid property clash. Insert the property with the highest priority in
-- an NCL document.

local function insert_properties (ncl, media, name, value)
   if name=="id" or name=="region" then
      return
   end

   for par in media:children() do
      if name == par.name then
         return
      end
   end

   local prop = ncl.new('property')
   prop.name = name
   prop.value = value
   media:insert (prop)
end

---
-- Removes all descriptors from NCL document. The function proceeds by
-- transforming the attributes of each media into equivalent parameters
-- of the associated descriptor.
-- @param ncl NCL document (root element).
-- @return the modified NCL document (root element).
---
function filter.apply (ncl)
   for desc in ncl:gmatch ('descriptor') do
      local list = {ncl:match ('media', 'descriptor', desc.id)}
      if #list == 0  then
         goto done
      end

      for _,media in ipairs (list) do
         for descpar in desc:children() do
            insert_properties (ncl, media, descpar.name, descpar.value)
         end


         for name, value in desc:attributes() do
            insert_properties (ncl, media, name, value)
         end

         media.descriptor = nil
      end

      ::done::
      xml.remove (desc:parent(), desc)
   end

   print (ncl)
   return (ncl)
end


return filter
