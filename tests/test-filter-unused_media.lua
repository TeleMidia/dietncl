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
local ipairs = ipairs
local print = print
local dietncl = require ('dietncl')
local xml = require ('dietncl.xmlsugar')
local filter = require ('dietncl.filter.unused_media')

_ENV = nil

local str = [[
<ncl>
 <head/>
 <body/>
</ncl>]]

-- Case 1
local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring (str)
assert (xml.equal (ncl, result))

-- Case 2
local str = [[
<ncl>
 <head/>
 <body>
  <media id="x"/>
 </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
 <head/>
 <body/>
</ncl>
]])

assert (xml.equal (ncl, result))

-- Case 3
local str = [[
<ncl>
 <head/>
 <body>
  <port id="p" component="y"/>
  <port id="e" component="x"/>
  <port id="g" component="z"/>
  <media id="z"/>
  <media id="d"/>
  <media id="x"/>
  <media id="y"/>
 </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
 <head/>
 <body>
  <port id="p" component="y"/>
  <port id="e" component="x"/>
  <port id="g" component="z"/>
  <media id="z"/>
  <media id="x"/>  
  <media id="y"/>
 </body>
</ncl>
]])

assert (xml.equal (ncl, result))

