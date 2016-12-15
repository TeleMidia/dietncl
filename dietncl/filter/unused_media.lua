--[[ filter.unused_media -- Remove unused medias.
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

-- Remove media elements that are not being referenced by link or port
-- elements.

local print = print

local filter = {}
local xml = require ('dietncl.xmlsugar')
_ENV = nil

function filter.apply (ncl)
   for med in ncl:gmatch ('media') do
      local list = {ncl:match ('port', 'component', med.id)}
      
      if #list == 0 then
	 xml.remove(med:parent (), med)
      end
   end

   print (ncl)
   return (ncl)
end


return filter
