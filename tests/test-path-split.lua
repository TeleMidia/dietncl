-- test-path-split.lua -- Checks path.split.
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

local path = require ('dietncl.path')

-- Empty path.
local dir, file = path.split ('')
assert (dir == '' and file == '')

dir, file = path.split ('abc')
assert (dir == '' and file == 'abc')

local dir, file = path.split ('.')
assert (dir == '' and file == '.')

dir, file = path.split ('..')
assert (dir == '' and file == '..')

dir, file = path.split ('./')
assert (dir == './' and file == '')

dir, file = path.split ('./././')
assert (dir == './././' and file == '')

dir, file = path.split ('/a')
assert (dir == '/' and file == 'a')

dir, file = path.split ('/a/b')
assert (dir == '/a/' and file == 'b')

dir, file = path.split ('a/b/c')
assert (dir == 'a/b/' and file == 'c')

dir, file = path.split ('/a/b/c/d//e')
assert (dir == '/a/b/c/d//' and file == 'e')

dir, file = path.split ('/a/b//c/d/')
assert (dir == '/a/b//c/d/' and file == '')
