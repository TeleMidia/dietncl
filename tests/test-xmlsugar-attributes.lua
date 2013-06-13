-- test-xmlsugar-attributes.lua -- Checks xmlsugar.attributes.
-- Copyright (C) 2013 PUC-Rio/Laboratorio TeleMidia
--
-- This file is part of DietNCL.
--
-- DietNCL is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DietNCL is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DietNCL.  If not, see <http://www.gnu.org/licenses/>.

require ('dietncl.xmlsugar')

local root = xml.eval ([[
<root a="1" b="2" c="3" d="4">
 <x/>
 <y/>
 <z/>
 <w/>
</root>
]])
local list = { a=1, b=2, c=3, d=4 }
local i = 0
for k,v in root:attributes () do
   assert (list[k] == tonumber (v))
   i = i + 1
end
assert (i == 4)
