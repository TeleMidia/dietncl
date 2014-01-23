--[[ dietncl -- The DietNCL API.
     Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia

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

local dietncl = {}
local assert = assert
local xml = require ('dietncl.xmlsugar')
_ENV = nil

---
-- Parses document string S.
-- Returns a new document handle if successful,
-- otherwise returns nil plus error message.
--
function dietncl.parsestring (s)
   local ncl, err = xml.eval (assert (s))
   if ncl == nil then
      return nil, err
   end
   return ncl
end

---
-- Parses document at path name PATHNAME.
-- Returns a new document handle if successful,
-- otherwise returns nil plus error message.
--
function dietncl.parse (pathname)
   local ncl, err = xml.load (assert (pathname))
   if ncl == nil then
      return nil, err
   end
   ncl:setuserdata ('pathname', pathname)
   return ncl
end

return dietncl
