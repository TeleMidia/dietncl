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
  <head>
    <connectorBase>
      <causalConnector id='c1'>
        <compoundCondition operator='and'>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='y' eventType='attribution' attributeType='nodeProperty'/>
            <attributeAssessment role='z' eventType='attribution' attributeType='nodeProperty'/>
          </assessmentStatement>
          <simpleCondition role='AAA' eventType='presentation' transition='starts'/>
        </compoundCondition>
        <simpleAction role='aaa' eventType='presentation' actionType='start'/>
      </causalConnector>
      <causalConnector id='c2'>
        <simpleCondition role='BBB' eventType='presentation' transition='stops'/>
        <simpleAction role='aaa' eventType='presentation' actionType='start'/>
      </causalConnector>
      <causalConnector id='c3'>
        <simpleCondition role='DDD' eventType='presentation' transition='pauses'/>
        <simpleAction role='bbb' eventType='presentation' actionType='stop'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='body'>
    <property name='taut' value='1'/>
    <port id='a' component='m1'/>
    <port id='b' component='m2'/>
    <media id='m1' src='m1.png'/>
    <media id='m2' src='m2.png'/>
    <media id='m3' src='m3.png'/>
    <media id='m4' src='m4.png'/>
    <link id='l1' xconnector='c1'>
      <bind role='AAA' component='m2'/>
      <bind role='y' component='body' interface='taut'/>
      <bind role='z' component='body' interface='taut'/>
      <bind role='aaa' component='m3'/>
    </link>
    <link id='l2' xconnector='c2'>
      <bind role='BBB' component='m3'/>
      <bind role='aaa' component='m4'/>
    </link>
    <link id='l3' xconnector='c3'>
      <bind role='DDD' component='m3'/>
      <bind role='bbb' component='m4'/>
    </link>
  </body>
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

   {{'stop', 'm3'},
      {true, 'start', 'm4'}},

   {{'pause', 'm3'},
      {true, 'stop', 'm4'}},

   {{'stop', 'm1'},
      {true, 'stop', 'lambda'}}
}

--assert (xml.equal (ncl, result))
print (t)
printt (t)

print (result)
printt (result)
