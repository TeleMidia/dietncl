--[[ Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia

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

local root = xml.eval ('<root/>')
local f = assert (root:gmatch ('x'))
assert (f () == nil)
assert (f () == nil)
assert (f () == nil)

local f = assert (root:gmatch ('root'))
assert (f () == root)
assert (f () == nil)
assert (f () == nil)

local root = xml.eval ([[
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

local f = assert (root:gmatch ('y'))
local y1 = assert (f ())
assert (y1.id == 'y1' and y1.a == '3')
local y2 = assert (f ())
assert (y2.id == 'y2' and y2.a == '4')
local y3 = assert (f ())
assert (y3.id == 'y3')
assert (f() == nil)

local f = assert (root:gmatch (nil, 'a'))
local y1 = assert (f ())
assert (y1.id == 'y1' and y1.a == '3')
local w = assert (f ())
assert (w.a == '3')
local y2 = assert (f ())
assert (y2.id == 'y2' and y2.a == '4')
assert (f () == nil)

local f = assert (root:gmatch (nil, '.', '^4$', 3))
local y2 = assert (f ())
assert (y2.id == 'y2' and y2.a == '4')

local f = assert (root:gmatch ())
local t = { 'root', 'x', 'y', 'z', 'w', 'y', 'y' }
for i=1,#t do
   assert ((f ()):tag () == t[i])
end
