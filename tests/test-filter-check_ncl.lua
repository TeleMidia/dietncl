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
local dietncl = require ('dietncl')
local xml = require ('dietncl.xmlsugar')
local filter = require ('dietncl.filter.check_ncl')

_ENV = nil


-- Simple NCL Document.

local str = [[
<ncl id='a'>
  <head/>
  <body/>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring (str)
assert (xml.equal (ncl, result))


-- Some optional attrs and children

local str = [[
<ncl id='a'>
  <head>
    <regionBase/>
  </head>
  <body id='b'/>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring (str)
assert (xml.equal (ncl, result))
