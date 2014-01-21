-- test-xmlsugar-userdata.lua -- Checks xmlsugar.{get,set}userdata.
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

local assert = assert

local xml = require ('dietncl.xmlsugar')
_ENV = nil

local e = xml.new ('e')
e:setuserdata ('x', 1)
e:setuserdata ('y', 2)
e:setuserdata ('z', 3)
assert (e:getuserdata ('x') == 1)
assert (e:getuserdata ('y') == 2)
assert (e:getuserdata ('z') == 3)
assert (e:getuserdata ('w') == nil)
e:setuserdata ('x', 3)
assert (e:getuserdata ('x') == 3)
e:setuserdata ('x', nil)
assert (e:getuserdata ('x') == nil)
