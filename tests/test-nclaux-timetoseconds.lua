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

local dietncl = require ('dietncl')
local aux = require ('dietncl.nclaux')
local util = require ('util')
local feq = util.feq
_ENV = nil

assert (aux.timetoseconds ('-33') == nil)
assert (aux.timetoseconds ('x') == nil)
assert (aux.timetoseconds ('5x') == nil)

assert (feq (aux.timetoseconds ('.55s'), .55))
assert (aux.timetoseconds ('5s') == 5)
assert (aux.timetoseconds ('25s') == 25)
assert (feq (aux.timetoseconds ('25.1s'), 25.1))

-- fraction
assert (aux.timetoseconds ('.') == 0)
assert (feq (aux.timetoseconds ('.25'), .25))

-- seconds
assert (aux.timetoseconds ('25') == 25)
assert (aux.timetoseconds (':25') == 25)

-- minutes
assert (aux.timetoseconds ('25:00') == 25*60)
assert (aux.timetoseconds ('25:') == 25*60)
assert (aux.timetoseconds (':25:') == 25*60)

-- hours
assert (aux.timetoseconds ('25:25:00') == 25*60*60 + 25*60)
assert (aux.timetoseconds ('25:25:') == 25*60*60 + 25*60)

-- misc
assert (feq (aux.timetoseconds ('25:77:44.339'), 25*60*60+77*60+44+.339))
assert (feq (aux.timetoseconds (':77:44.339'), 0*60*60+77*60+44+.339))
