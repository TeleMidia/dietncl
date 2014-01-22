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
local ipairs = ipairs

local dietncl = require ('dietncl')
local filter = require ('dietncl.filter.prenorm1')

_ENV = nil


-- No connectors: do nothing.

local str = [[
<ncl>
 <head>
  <regionBase/>
 </head>
 <body/>
</ncl>]]

local ncl = dietncl.parsestring (str)
filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring (str)))


-- Single, pre-normalized link-connector pair: do nothing.

str = [[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleCondition role='onBegin'/>
    <simpleAction role='stop'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onBegin' component='m'/>
   <bind role='stop' component='m'/>
  </link>
 </body>
</ncl>]]

ncl = dietncl.parsestring (str)
filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring (str)))


-- Remove unused connectors (all).

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onBegin'/>
    <simpleAction role='stop'/>
   </causalConnector>
   <causalConnector id='c2'>
    <compoundCondition operator='or'>
     <compoundCondition role='onEnd'/>
     <compoundCondition role='onSelection'/>
    </compoundCondition>
    <simpleCondition role='pause'/>
   </causalConnector>
   <causalConnector id='c3'>
    <simpleCondition role='onAbort'/>
    <simpleAction role='abort'/>
   </causalConnector>
   <causalConnector id='c4'>
    <simpleCondition role='onPause'/>
    <simpleAction role='pause'/>
   </causalConnector>
  </connectorBase>
  <descriptorBase>
  </descriptorBase>
 </head>
 <body>
 </body>
</ncl>]])

filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase/>
  <descriptorBase/>
 </head>
 <body/>
</ncl>]])))


-- Eliminate connector reuse.

local function check_bijection (ncl)
   local connlist = {ncl:match ('causalConnector')}
   local linklist = {ncl:match ('link')}

   assert (#connlist == #linklist)

   for _,link in ipairs (linklist) do
      for i=1,#linklist do
         if link ~= linklist[i] then
            assert (link.xconnector ~= linklist[i].xconnector)
         end
      end
   end
end

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleAction role='stop'/>
    <simpleCondition role='onEnd'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <media id='n'/>
  <link xconnector='c'>
   <bind role='onEnd' component='m'/>
   <bind role='stop' component='n'/>
  </link>
  <link xconnector='c'>
   <bind role='onEnd' component='n'/>
   <bind role='stop' component='m'/>
  </link>
  <link xconnector='c'>
   <bind role='onEnd' component='m'/>
   <bind role='stop' component='m'/>
  </link>
  <link xconnector='c'>
   <bind role='onEnd' component='n'/>
   <bind role='stop' component='n'/>
  </link>
 </body>
</ncl>]])

filter.apply (ncl)
check_bijection (ncl)

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onBegin'/>
    <simpleAction role='start'/>
   </causalConnector>
   <causalConnector id='c2'>
    <simpleCondition role='onEnd'/>
    <simpleAction role='stop'/>
   </causalConnector>
   <causalConnector id='c3'>
    <simpleCondition role='onAbort'/>
    <simpleAction role='pause'/>
   </causalConnector>
   <causalConnector id='c4'>
    <simpleCondition role='onSelection'/>
    <simpleAction role='start'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <media id='n'/>
  <media id='x'/>
  <link xconnector='c1'>
   <bind role='onBegin' component='m'/>
   <bind role='start' component='n'/>
  </link>
  <link xconnector='c1'>
   <bind role='onBegin' component='n'/>
   <bind role='start' component='m'/>
  </link>
  <link xconnector='c2'>
   <bind role='onEnd' component='m'/>
   <bind role='stop' component='m'/>
  </link>
  <link xconnector='c2'>
   <bind role='onEnd' component='m'/>
   <bind role='stop' component='n'/>
  </link>
  <link xconnector='c2'>
   <bind role='onEnd' component='n'/>
   <bind role='stop' component='x'/>
  </link>
  <link xconnector='c1'>
   <bind role='onBegin' component='n'/>
   <bind role='start' component='n'/>
  </link>
  <link xconnector='c4'>
   <bind role='onSelection' component='n'/>
   <bind role='start' component='n'/>
  </link>
 </body>
</ncl>]])

filter.apply (ncl)
check_bijection (ncl)
