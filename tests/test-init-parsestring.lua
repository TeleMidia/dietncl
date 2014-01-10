-- test-init-parsestring.lua -- Checks dietncl.parsestring.
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

require ('dietncl')

assert (dietncl.parsestring ('') == nil)

file, err = io.open ('tests/test-init-parse-sample.ncl', 'r')
assert (file ~= nil)

ncl = dietncl.parsestring (file:read ('*a'))
file:close ()

assert (ncl:getuserdata ('pathname') == nil)
assert (ncl:tag () == 'ncl')
assert (ncl.id == 'test-init-parse-sample')
assert (#ncl == 2)
assert (ncl[1]:tag () == 'head')
assert (ncl[2]:tag () == 'body')
