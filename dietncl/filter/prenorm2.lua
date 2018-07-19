--[[ filter.prenorm2 -- Second pre-normalization step.
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

_ENV = nil

---
-- Guarantees that all connectors and links contain no link, bind
-- or connector parameters.
--
-- Dependencies: `dietncl.filter.prenorm1`
-- @module dietncl.filter.prenorm2
---

---
-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM2, implements the second pre-normalization
-- step: It guarantees that all connectors and links contain no link, bind,
-- or connector parameters, i.e., no <linkParam>, <bindParam>, or
-- <connectorParam> elements (except if "pega-dali" is used).
-- @param ncl NCL document (root element).
-- @return the modified NCL document (root element).
---
function filter.apply (ncl)
   for conn in ncl:gmatch ('causalConnector') do

      local dont_delete = {} -- connector parameters that we can't delete
      local link             -- link associated with connector conn

      link = ncl:match ('link', 'xconnector', conn.id)

      for bind in link:gmatch ('bind') do

         local bindref = conn:match (nil, 'role', bind.role)
         if bindref == nil then
            goto continue       -- nothing to do ("pega dali")
         end

         for k,v in bindref:attributes () do

            if v:sub(1,1) ~= '$' then
               goto continue    -- nothing to do
            end

            local name = v:sub (2)
            local connparam = conn:match ('connectorParam', 'name', name)
            if connparam == nil then
               goto continue    -- nothing to do
            end

            -- Get the associated bind-parameter.
            local bindparam
            if #bind == 0 then
               local p = link:match ('linkParam', 'name', name)
               if p == nil then
                  goto continue -- nothing to do
               end
               bindparam = xml.new ('bindParam')
               bindparam.name = p.name
               bindparam.value = p.value
               bind:insert (bindparam)
            else
               bindparam = bind[1]
            end

            -- If is an infamous "pega-dali", then don't delete.
            if bindparam.value:sub (1,1) == '$' then
               dont_delete[connparam] = true
               goto continue
            end

            -- Replace bind's value for connector's value and remove the
            -- bind-parameter.
            bindref[k] = bindparam.value
            bind:remove (bindparam)

            ::continue::
         end

         ::continue::
      end

      -- Remove the connector parameters from conn that are not used by some
      -- infamous "pega-dali".
      for p in conn:gmatch ('connectorParam') do
         if dont_delete[p] then
            goto continue       -- do nothing
         end
         conn:remove (p)
         ::continue::
      end

      -- Remove all link-parameters from link.
      for p in link:gmatch ('linkParam') do
         link:remove (p)
      end
   end

   return ncl
end

return filter
