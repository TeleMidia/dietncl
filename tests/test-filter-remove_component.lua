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
local ipairs = ipairs
local print = print
local dietncl = require ('dietncl')
local xml = require ('dietncl.xmlsugar')
local filter = require ('dietncl.filter.remove_component')

_ENV = nil


-- No media nor context: do nothing.

local str = [[
<ncl>
 <head/>
 <body/>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring (str)
assert (xml.equal (ncl, result))


-- Remove unused media/context (all).
local str = [[
<ncl>
  <head/>
  <body>
    <context id="a"/>
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


-- Remove unused media ("d").
local str = [[
<ncl>
  <head/>
  <body>
    <port id="p" component="y"/>
    <port id="e" component="x"/>
    <port id="g" component="z"/>
    <media id="z"/>
    <context id="a"/>
    <media id="d"/>
    <media id="x"/>
    <media id="y"/>
    <link id="l">
      <bind role="onSelection" component="a"/>
    </link>
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
    <context id="a"/>
    <media id="x"/>
    <media id="y"/>
    <link id="l">
      <bind role="onSelection" component="a"/>
    </link>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Single, pre-normalized port-context pair: do nothing.
local str = [[
<ncl>
  <head/>
  <body>
    <context id="a">
    </context>
    <link id="l">
      <bind role="onSelection" component="b"/>
    </link>
    <port id="e" component="a"/>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <context id="a">
    </context>
    <link id="l">
      <bind role="onSelection" component="b"/>
    </link>
    <port id="e" component="a"/>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Remove only the context that is being referenced only within itself
local str = [[
<ncl>
  <head/>
  <body>
    <port id="p0" component="c1"/>
    <context id="c1">
      <port id="p1" component="c2"/>
      <context id="c2"/>
      <context id="c3">
        <context id="c4"/>
        <port id="p2" component="c3"/>
      </context>
    </context>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <port id="p0" component="c1"/>
    <context id="c1">
      <port id="p1" component="c2"/>
      <context id="c2"/>
    </context>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))


-- Remove all contexts
local str = [[
<ncl>
  <head/>
  <body>
    <context id="c1">
      <port id="p1" component="c2"/>
      <context id="c2"/>
      <context id="c3">
        <context id="c4"/>
        <port id="p2" component="c3"/>
      </context>
    </context>
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


-- Remove unreferenced contexts
local str = [[
<ncl>
  <head/>
  <body>
    <port id="p0" component="c1"/>
    <context id="c1">
      <context id="c2"/>
      <context id="c3">
        <context id="c4"/>
        <port id="p2" component="c3"/>
      </context>
    </context>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))

local result = dietncl.parsestring ([[
<ncl>
  <head/>
  <body>
    <port id="p0" component="c1"/>
    <context id="c1"/>
  </body>
</ncl>
]])

assert (xml.equal (ncl, result))
