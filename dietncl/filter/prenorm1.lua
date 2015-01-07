--[[ filter.prenorm1 -- First pre-normalization step.
     Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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

-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM1, implements the first pre-normalization
-- step: It guarantees that each connector is referenced by exactly one
-- link.
--
-- Depends: IMPORT.

local filter = {}
local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

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

      for i=1,#list-1 do
         local parent = conn:parent ()
         local dup = conn:clone ()

         dup.id = aux.gen_id (ncl)
         list[i].xconnector = dup.id
         parent:insert (dup)
      end
      ::continue::
   end
   return ncl
end

return filter
