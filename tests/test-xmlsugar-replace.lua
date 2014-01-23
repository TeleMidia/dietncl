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

local root = xml.new ('root')
local x = xml.new ('x')
local y = xml.new ('y')
local z = xml.new ('z')
local w = xml.new ('w')

assert (root:insert (x) == 1)
assert (x:insert (y) == 1)
assert (x:insert (z) == 2)

-- Old denotes a position.
local w = xml.new ('w')
local rep, pos = x:replace (1, w)
assert (rep == y and pos == 1)
assert (y:parent () == nil)
assert (w:parent () == x)

local rep, pos = root:replace (1, y)
assert (rep == x and pos == 1)
assert (root:replace (1, x) == y)

-- Old denotes an element.
local rep, pos = x:replace (z, y)
assert (rep == z and pos == 2)
assert (x[2] == y)
assert (y:parent () == x)
assert (z:parent () == nil)

assert (x:remove (y) == y)
assert (x:replace (w, y) == w)
assert (x[1] == y)
assert (w:parent () == nil)
