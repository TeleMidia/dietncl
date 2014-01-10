-- test-xmlsugar-insert.lua -- Checks xmlsugar.insert.
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

root = xml.new ('root')
x = xml.new ('x')
y = xml.new ('y')
z = xml.new ('z')
w = xml.new ('w')

assert (root:insert (-1, x) == nil)
assert (root:insert (5, x) == nil)

assert (root:insert (x) == 1)
assert (root:insert (y) == 2)
assert (root:insert (1, z) == 1)
assert (root:insert (2, w) == 2)

a = xml.new ('a')
b = xml.new ('b')
c = xml.new ('c')

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

tree = xml.new ('tree')
r = xml.new ('r')
s = xml.new ('s')
t = xml.new ('t')
u = xml.new ('u')

assert (r:insert (s) == 1)
assert (t:insert (u) == 1)
assert (tree:insert (r) == 1)
assert (tree:insert (t) == 2)
assert (w:insert (tree) == 1)
