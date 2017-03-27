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
local pairs = pairs
local print = print
local type = type
local table = table

local dietncl = require ('dietncl')
local xml = require ('dietncl.xmlsugar')
local filter = require ('dietncl.filter.smix')

_ENV = nil

local function printt (ncl)
   for k, elt in pairs (ncl) do
      local str = '['..k..']'
      if type (elt) == 'table' then
         print ('t['..k..']')
         printt (elt)
      else
         print (elt)
      end
   end
end



-- No media nor context: do nothing.

local str = [[
<ncl id='x'>
  <port id='a' component='m1'/>
  <port id='b' component='m2'/>
  <link id='l1' xconnector='##'>
    <bind role='onBegin' component='m2'/>
    <bind role='start' component='m3'/>
  </link>
  <link id='l2' xconnector='###'>
    <bind role='onEnd' component='m3'/>
    <bind role='start' component='m4'/>
  </link>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local t = filter.apply (ncl)
assert (t)

local result = {
   { m1 = {uri='m1.png'},
     m2 = {uri='m2.png'},
     m3 = {uri='m3.png'}
   },

   {{'start', 'lambda'},
      {true, 'start', 'm1'},
      {true, 'start', 'm2'}},

   {{'start', 'm2'},
      {true, 'start', 'm3'}},

   {{'start', 'm3'},
      {true, 'start', 'm4'}},

   {{'stop', 'm1'},
      {true, 'stop', 'lambda'}}
}

--assert (xml.equal (ncl, result))
print (t)
printt (t)

print (result)
printt (result)
