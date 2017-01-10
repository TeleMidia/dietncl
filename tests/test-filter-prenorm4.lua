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
local filter = require ('dietncl.filter.prenorm4')

_ENV = nil

local str = [[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleCondition role='onBegin' transition='onBegin' eventType='presentation'/>
    <simpleAction role='start' actionType='start' eventType='presentation'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onBegin' component='m'/>
   <bind role='start' component='m'/>
  </link>
 </body>
</ncl>]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring (str)))

local ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleCondition role='onBegin'/>
    <simpleAction role='start'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m1'/>
  <media id='m2'/>
  <media id='m3'/>
  <media id='m4'/>
  <link xconnector='c'>
   <bind role='onBegin' component='m1'/>
   <bind role='start' component='m1'/>
   <bind role='onBegin' component='m2'/>
   <bind role='start' component='m2'/>
   <bind role='onBegin' component='m3'/>
   <bind role='start' component='m3'/>
   <bind role='onBegin' component='m4'/>
   <bind role='start' component='m4'/>
  </link>
 </body>
</ncl>
]])

assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <compoundCondition operator='and'>
     <simpleCondition eventType='presentation' transition='onBegin'
                      role='onBegin'/>
     <simpleCondition role='___0' eventType='presentation'
                      transition='onBegin'/>
     <simpleCondition role='___2' eventType='presentation'
                      transition='onBegin'/>
     <simpleCondition role='___4' eventType='presentation'
                      transition='onBegin'/>
    </compoundCondition>
    <compoundAction operator='par'>
     <simpleAction eventType='presentation' role='start'
                   actionType='start'/>
     <simpleAction role='___1' eventType='presentation' actionType='start'/>
     <simpleAction role='___3' eventType='presentation' actionType='start'/>
     <simpleAction role='___5' eventType='presentation' actionType='start'/>
    </compoundAction>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m1'/>
  <media id='m2'/>
  <media id='m3'/>
  <media id='m4'/>
  <link xconnector='c'>
   <bind role='onBegin' component='m1'/>
   <bind role='start' component='m1'/>
   <bind role='___0' component='m2'/>
   <bind role='___1' component='m2'/>
   <bind role='___2' component='m3'/>
   <bind role='___3' component='m3'/>
   <bind role='___4' component='m4'/>
   <bind role='___5' component='m4'/>
  </link>
 </body>
</ncl>
]])))
