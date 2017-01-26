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
local print = print
local dietncl = require ('dietncl')
local xml = require ('dietncl.xmlsugar')
local filter = require ('dietncl.filter.descriptor')

_ENV = nil


-- Remove descriptor and descriptorParam and insert the correct properties
-- to media element.

local str = [[
<ncl>
  <head>
    <descriptor id='d1' top='5%'>
      <descriptorParam name='top' value='6%'/>
      <descriptorParam name='left' value='10%'/>
    </descriptor>
  </head>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png' descriptor='d1'/>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'>
      <property name='top' value='6%'/>
      <property name='left' value='10%'/>
    </media>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Ignores the descriptorParam that clashes with the existent media property.

local str = [[
<ncl>
  <head>
    <descriptor id='d1' top='5%'>
      <descriptorParam name='top' value='6%'/>
      <descriptorParam name='left' value='10%'/>
    </descriptor>
  </head>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png' descriptor='d1'>
      <property name='top' value='15%'/>
    </media>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'>
      <property name='top' value='15%'/>
      <property name='left' value='10%'/>
    </media>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Descriptor with no parameters attached (only descriptorParam).

local str = [[
<ncl>
  <head>
    <descriptor id='d1'>
      <descriptorParam name='top' value='6%'/>
      <descriptorParam name='left' value='10%'/>
    </descriptor>
  </head>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png' descriptor='d1'/>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'>
      <property name='top' value='6%'/>
      <property name='left' value='10%'/>
    </media>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Remove descriptor that is not being referenced.

local str = [[
<ncl>
  <head>
    <descriptor id='d1' top='5%'>
      <descriptorParam name='top' value='6%'/>
      <descriptorParam name='left' value='10%'/>
    </descriptor>
  </head>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'/>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'/>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Removes unreferenced descriptor ('d2').


local str = [[
<ncl>
  <head>
   <descriptorBase>
    <descriptor id='d1' top='5%'>
      <descriptorParam name='top' value='6%'/>
      <descriptorParam name='left' value='10%'/>
    </descriptor>
    <descriptor id='d2'/>
   </descriptorBase>
  </head>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'/>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head>
    <descriptorBase/>
  </head>
  <body>
    <port id='p' component='m'/>
    <media id='m' src='test.png'/>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))
