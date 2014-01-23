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
local filter = require ('dietncl.filter.prenorm3')
_ENV = nil

local ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <compoundCondition operator='or' delay='5s'>
     <compoundCondition operator='and' delay='10s'>
      <simpleCondition role='onEnd' delay='15s'/>
     </compoundCondition>
     <simpleCondition role='onBegin'/>
    </compoundCondition>
    <compoundAction operator='seq' delay='10s'>
     <compoundAction operator='seq' delay='10s'>
      <compoundAction operator='seq' delay='10s'>
       <simpleAction role='start' delay='00:01'/>
      </compoundAction>
     </compoundAction>
     <simpleAction role='stop'/>
    </compoundAction>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onEnd' component='m'/>
   <bind role='onBegin' component='m'/>
   <bind role='start' component='m'/>
   <bind role='stop' component='m'/>
  </link>
 </body>
</ncl>]])

assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <compoundCondition operator='or'>
     <compoundCondition operator='and'>
      <simpleCondition role='onEnd' delay='30s'/>
     </compoundCondition>
     <simpleCondition role='onBegin' delay='5s'/>
    </compoundCondition>
    <compoundAction operator='seq'>
     <compoundAction operator='seq'>
      <compoundAction operator='seq'>
       <simpleAction role='start' delay='31s'/>
      </compoundAction>
     </compoundAction>
     <simpleAction role='stop' delay='10s'/>
    </compoundAction>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onEnd' component='m'/>
   <bind role='onBegin' component='m'/>
   <bind role='start' component='m'/>
   <bind role='stop' component='m'/>
  </link>
 </body>
</ncl>]])))
