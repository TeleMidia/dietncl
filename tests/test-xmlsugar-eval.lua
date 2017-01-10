--[[ Copyright (C) 2013-2017 PUC-Rio/Laboratorio TeleMidia

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
local xml = require ('dietncl.xmlsugar')
_ENV = nil

assert (xml.eval ('') == nil)
assert (xml.eval ('x') == nil)
assert (xml.eval (nil) == nil)

local root = xml.eval ([[
<root>
 <x/>
 <y>
  <a/>
  <b/>
  <c>
   <r>
    <s/>
   </r>
  </c>
 </y>
 <z/>
 <w/>
</root>
]])
assert (root)
assert (root:parent () == nil and #root == 4)

local function check (e, tag, parent, n)
   assert (e:tag () == tag and e:parent () == parent and #e == n)
end

check (root[1], 'x', root, 0)
check (root[2], 'y', root, 3)
check (root[3], 'z', root, 0)
check (root[4], 'w', root, 0)

local y = root[2]
check (y[1], 'a', y, 0)
check (y[2], 'b', y, 0)
check (y[3], 'c', y, 1)

local c = y[3]
check (c[1], 'r', c, 1)

local r = c[1]
check (r[1], 's', r, 0)
