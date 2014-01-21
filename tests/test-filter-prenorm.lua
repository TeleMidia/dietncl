-- test-filter-prenorm.lua -- Checks filter.prenorm.
-- Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
--
-- This file is part of DietNCL.
--
-- DietNCL is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DietNCL is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DietNCL.  If not, see <http://www.gnu.org/licenses/>.

local assert = assert
local ipairs = ipairs
local print = print

local dietncl = require ('dietncl')
local aux = require ('dietncl.nclaux')
local filter = require ('dietncl.filter.prenorm')
local util = require ('util')
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
--[==[
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


-- Expand link, bind, and connector parameters.

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <connectorParam name='p1' type='x'/>
    <connectorParam name='p2' type='y'/>
    <simpleCondition role='onBegin' delay='$p1'/>
    <simpleAction role='start' delay='$p2'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <linkParam name='p1' value='5s'/>
   <bind role='onBegin'/>
   <bind role='start'>
    <bindParam name='p2' value='10s'/>
  </link>
 </body>
</ncl>]])

filter.apply (ncl)
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleCondition role='onBegin' delay='5s'/>
    <simpleAction role='start' delay='10s'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onBegin'/>
   <bind role='start'/>
 </body>
</ncl>]])))


--  Don't expand the infamous "pega-dali".

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c1'>
    <connectorParam name='p'/>
     <compoundCondition operator='and'>
      <compoundCondition operator='and'>
       <compoundCondition operator='and'>
        <simpleCondition role='onSelection' key='$p'/>
       </compoundCondition>
      </compoundCondition>
    </compoundCondition>
    <simpleAction role='start'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body id='body'>
  <property name='p' value='RED'/>
  <media id='x'/>
  <media id='y'/>
  <media id='z'/>
  <link xconnector='c1'>
   <linkParam name='p' value='$get'/>
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'/>
   <bind role='start' component='y'/>
  </link>
  <link xconnector='c1'>
   <linkParam name='p' value='RED'/>
   <bind role='onSelection' component='x'/>
   <bind role='start' component='z'/>
  </link>
  <link xconnector='c1'>
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'>
    <bindParam name='p' value='$get'/>
   </bind>
   <bind role='start' component='x'/>
  </link>
 </body>
</ncl>]])

filter.apply (ncl)

local _, prefix, serial = aux.get_last_gen_id (ncl)
local c2 = prefix..(serial - 1)
local c3 = prefix..serial
assert (ncl:equal (util.parsenclformat ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c1'>
    <connectorParam name='p'/>
     <compoundCondition operator='and'>
      <compoundCondition operator='and'>
       <compoundCondition operator='and'>
        <simpleCondition role='onSelection' key='$p'/>
       </compoundCondition>
      </compoundCondition>
    </compoundCondition>
    <simpleAction role='start'/>
   </causalConnector>
   <causalConnector id='%s'>
    <connectorParam name='p'/>
     <compoundCondition operator='and'>
      <compoundCondition operator='and'>
       <compoundCondition operator='and'>
        <simpleCondition role='onSelection' key='$p'/>
       </compoundCondition>
      </compoundCondition>
    </compoundCondition>
    <simpleAction role='start'/>
   </causalConnector>
   <causalConnector id='%s'>
     <compoundCondition operator='and'>
      <compoundCondition operator='and'>
       <compoundCondition operator='and'>
        <simpleCondition role='onSelection' key='RED'/>
       </compoundCondition>
      </compoundCondition>
    </compoundCondition>
    <simpleAction role='start'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body id='body'>
  <property name='p' value='RED'/>
  <media id='x'/>
  <media id='y'/>
  <media id='z'/>
  <link xconnector='%s'>
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'>
    <bindParam name="p" value="$get" />
   </bind>
   <bind role='start' component='y'/>
  </link>
  <link xconnector='%s'>
   <bind role='onSelection' component='x'/>
   <bind role='start' component='z'/>
  </link>
  <link xconnector='c1'>
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'>
    <bindParam name='p' value='$get'/>
   </bind>
   <bind role='start' component='x'/>
  </link>
 </body>
</ncl>]], c2, c3, c2, c3)))


-- Eliminate "delay" from compound conditions and actions.

ncl = dietncl.parsestring ([[
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

filter.apply (ncl)
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

-- Expand simple conditions and simple actions.
print (('-'):rep (80))

ncl = dietncl.parsestring ([[
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
   <bind role='onEnd' component='m'/>
   <bind role='onEnd' component='m'/>
   <bind role='onBegin' component='m'/>
   <bind role='start' component='m'/>
   <bind role='start' component='m'/>
   <bind role='start' component='m'/>
   <bind role='start' component='m'/>
   <bind role='stop' component='m'/>
  </link>
 </body>
</ncl>]])

filter.apply (ncl)
]==]--

-- Test for restriction (5).

print (('-'):rep (80))

ncl = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <simpleCondition role='onBegin' delay='5s'/>
	<simpleCondition role='onSelection'/>
	<simpleCondition role='onEnd'/>
    <simpleAction role='start' delay='10s'/>
   </causalConnector>

   <causalConnector id='a'>
	<simpleCondition role='onEnd'/>
	<compoundAction operator='seq'>
       <simpleAction role='start' delay='31s'/>
	</compoundAction>
	<compoundAction operator='seq'>
       <simpleAction role='stop' delay='31s'/>
	</compoundAction>
	<compoundAction operator='seq'>
       <simpleAction role='pause' delay='31s'/>
	</compoundAction>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <bind role='onBegin'/>
   <bind role='onSelection'/>
   <bind role='start'/>
  </link>
  <link xconnector='a'>
   <bind role='onEnd'/>
   <bind role='start'/>
   <bind role='stop'/>
   <bind role='pause'/>
  </link>
 </body>
</ncl>]])

filter.apply (ncl)
