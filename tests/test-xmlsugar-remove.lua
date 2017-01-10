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

local root = xml.new ('root')
local x = xml.new ('x')
local y = xml.new ('y')
local z = xml.new ('z')
local w = xml.new ('w')

assert (root:insert (x) == 1)
assert (x:insert (y) == 1)
assert (x:insert (z) == 2)
assert (y:insert (w) == 1)

-- Child denotes a position.
assert (x:remove (1) == y)
assert (y:parent () == nil)
assert (root[1] == x)
assert (x[1] == z)
assert (#z == 0)

assert (y:parent () == nil)
assert (y[1] == w)
assert (w:parent () == y)

assert (root:insert (1, y))
assert (y:parent () == root)

-- Child denotes an element.
assert (root:remove (y) == y)
assert (y:parent () == nil)
assert (root[1] == x)
assert (x:remove (z) == z)
assert (root[1] == x and #x == 0)
