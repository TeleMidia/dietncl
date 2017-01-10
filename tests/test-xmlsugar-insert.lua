--[[ Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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
local pcall = pcall
local xml = require ('dietncl.xmlsugar')
_ENV = nil

local root = xml.new ('root')
local x = xml.new ('x')
local y = xml.new ('y')
local z = xml.new ('z')
local w = xml.new ('w')

assert (not pcall (root.insert, root, -1, x))
assert (not pcall (root.insert, root, 5, x))

assert (root:insert (x) == 1)
assert (root:insert (y) == 2)
assert (root:insert (1, z) == 1)
assert (root:insert (2, w) == 2)

local a = xml.new ('a')
local b = xml.new ('b')
local c = xml.new ('c')

assert (x:insert (a) == 1)
assert (y:insert (b) == 1)
assert (z:insert (c) == 1)

assert (#x == 1)
assert (#y == 1)
assert (#z == 1)
assert (#w == 0)

assert (root:parent () == nil)
assert (x:parent () == root)
assert (y:parent () == root)
assert (z:parent () == root)
assert (w:parent () == root)

assert (a:parent () == x)
assert (b:parent () == y)
assert (c:parent () == z)

local tree = xml.new ('tree')
local r = xml.new ('r')
local s = xml.new ('s')
local t = xml.new ('t')
local u = xml.new ('u')

assert (r:insert (s) == 1)
assert (t:insert (u) == 1)
assert (tree:insert (r) == 1)
assert (tree:insert (t) == 2)
assert (w:insert (tree) == 1)
