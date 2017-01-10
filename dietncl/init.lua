--[[ dietncl -- The DietNCL API.
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

local assert = assert

local xml = require'dietncl.xmlsugar'
local dietncl = {}
_ENV = nil

---
-- Parsing, representation, and manipulation of NCL documents.
-- @module dietncl
---

---
-- Parses document string.
-- @param s document string.
-- @return[1] document tree (root element), if successful.
-- @return[2] `nil` plus error message, otherwise.
---
function dietncl.parsestring (s)
   local ncl, err = xml.eval (assert (s))
   if ncl == nil then
      return nil, err
   end
   return ncl
end

---
-- Parses document file.
-- @param path path to document file.
-- @return[1] document tree (root element), if successful.
-- @return[2] `nil` plus error message, otherwise.
---
function dietncl.parse (path)
   local ncl, err = xml.load (assert (path))
   if ncl == nil then
      return nil, err
   end
   ncl:setuserdata ('pathname', path)
   return ncl
end

return dietncl
