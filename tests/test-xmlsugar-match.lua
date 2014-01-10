-- test-xmlsugar-match.lua -- Checks xmlsugar.match.
-- Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
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

-- 
-- -- Match plain strings.

root = xml.eval ('<root/>')
assert (root:match ('x') == nil)

t = {root:match ('root')}
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
t = {root:match ('y')}
assert (#t == 3)
assert (t[1].id == 'y1')
assert (t[2].id == 'y2')
assert (t[3].id == 'y3')

t = {root:match ('y', 'a')}
assert (#t == 2)
assert (t[1].id == 'y1')
assert (t[2].id == 'y2')

t = {root:match ('y', 'a', '4')}
assert (#t == 1)
assert (t[1].id == 'y2')

t = {root:match (nil, 'id')}
assert (#t == 3)
assert (t[1]:tag () == 'y' and t[1].id == 'y1')
assert (t[2]:tag () == 'y' and t[2].id == 'y2')
assert (t[3]:tag () == 'y' and t[3].id == 'y3')

t = {root:match (nil, 'a', '4')}
assert (#t == 1)
assert (t[1]:tag () == 'y' and t[1].id == 'y2')


-- Match regexps.

root = xml.eval ('<root/>')
assert (root:match ('r', nil, nil, 4))
assert (root:match ('x', nil, nil, 4) == nil)

t = {root:match ('ro.t', nil, nil, 4)}
assert (t[1]:tag () == 'root' and #t == 1)

root = xml.eval ("<root abc='xyz'/>")
assert (root:match ('root', 'abc', 'xyz', 0))
assert (root:match ('roo', 'abc', 'xyz', 0) == nil)
assert (root:match ('root', 'ab', 'xyz', 0) == nil)
assert (root:match ('root', 'abc', 'xy', 0) == nil)

assert (root:match ('root', 'abc', 'xyz', 0)) -- 000
assert (root:match ('root', 'abc', 'xy.', 1)) -- 001
assert (root:match ('root', 'ab.', 'xyz', 2)) -- 010
assert (root:match ('root', 'ab.', 'xy.', 3)) -- 011
assert (root:match ('roo.', 'abc', 'xyz', 4)) -- 100
assert (root:match ('roo.', 'abc', 'xy.', 5)) -- 101
assert (root:match ('roo.', 'ab.', 'xyz', 6)) -- 110
assert (root:match ('roo.', 'ab.', 'xy.', 7)) -- 111

root = xml.eval ([[
<root>
 <x/>
 <y id='y1' a='3'/>
 <z>
  <w a='3'>
   <y id='y2' a='4'/>
  </w>
 </z>
 <y id='y33'/>
</root>]])
t = {root:match (nil, '^[^a]*$', '^[a-z][0-9]$', 3)}
assert (#t == 2)
assert (t[1].id == 'y1')
assert (t[2].id == 'y2')
