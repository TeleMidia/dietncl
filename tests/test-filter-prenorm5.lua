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
local filter = require ('dietncl.filter.prenorm5')

_ENV = nil

local ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleCondition role='onBegin' delay='5s'/>
     <simpleCondition role='onSelection'/>
     <simpleCondition role='onEnd'/>
	 <compoundAction operator='par'>
	 </compoundAction>
	 <compoundAction operator='seq'>
	 <simpleAction role='pause'/>
	 </compoundAction>
	 <compoundAction operator='par'>
	 <simpleAction role='start'/>
	 </compoundAction>
    <simpleAction role='start' delay='10s'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onBegin'/>
   <bind role='onSelection'/>
   <bind role='start'/>
   <bind role='onEnd'>
 </body>
</ncl>]])

assert(filter.apply(ncl))

