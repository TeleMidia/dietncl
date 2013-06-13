-- test-xmlsugar-match.lua -- Checks xmlsugar.match.
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

local root = xml.eval ('<root/>')
local t = root:match ('x')
assert (#t == 0)

t = root:match ('root')
assert (t[1]:tag () == 'root' and #t == 1)

root = xml.eval ([[
<root>
 <x/>
 <y id='y1' a='3'/>
 <z>
  <w a='3'>
   <y id='y2' a='4'/>
  </w>
 </z>
 <y id='y3'/>
</root>]])
t = root:match ('y')
assert (#t == 3)
assert (t[1].id == 'y1')
assert (t[2].id == 'y2')
assert (t[3].id == 'y3')

t = root:match ('y', 'a')
assert (#t == 2)
assert (t[1].id == 'y1')
assert (t[2].id == 'y2')

t = root:match ('y', 'a', '4')
assert (#t == 1)
assert (t[1].id == 'y2')

t = root:match (nil, 'id')
assert (#t == 3)
assert (t[1]:tag () == 'y' and t[1].id == 'y1')
assert (t[2]:tag () == 'y' and t[2].id == 'y2')
assert (t[3]:tag () == 'y' and t[3].id == 'y3')

t = root:match (nil, 'a', '4')
assert (#t == 1)
assert (t[1]:tag () == 'y' and t[1].id == 'y2')
