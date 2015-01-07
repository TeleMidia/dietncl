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
local path = require ('dietncl.path')
_ENV = nil

local dir, file = path.split ('')
assert (dir == '' and file == '')

local dir, file = path.split ('abc')
assert (dir == '' and file == 'abc')

local dir, file = path.split ('.')
assert (dir == '' and file == '.')

local dir, file = path.split ('..')
assert (dir == '' and file == '..')

local dir, file = path.split ('./')
assert (dir == './' and file == '')

local dir, file = path.split ('./././')
assert (dir == './././' and file == '')

local dir, file = path.split ('/a')
assert (dir == '/' and file == 'a')

local dir, file = path.split ('/a/b')
assert (dir == '/a/' and file == 'b')

local dir, file = path.split ('a/b/c')
assert (dir == 'a/b/' and file == 'c')

local dir, file = path.split ('/a/b/c/d//e')
assert (dir == '/a/b/c/d//' and file == 'e')

local dir, file = path.split ('/a/b//c/d/')
assert (dir == '/a/b//c/d/' and file == '')
