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
local filter = require ('dietncl.filter.prenorm2')
local aux = require ('dietncl.nclaux')

local print = print

_ENV = nil


-- Expand link, bind, and connector parameters.

local ncl, errmsg = dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c'>
    <connectorParam name='p1'/>
    <connectorParam name='p2'/>
    <simpleCondition role='onBegin' delay='$p1'/>
    <simpleAction role='start' delay='$p2'/>
   </causalConnector>
  </connectorBase>
 </head>
 <body>
  <media id='m'/>
  <link xconnector='c'>
   <linkParam name='p1' value='5s'/>
   <bind role='onBegin' component='m'/>
   <bind role='start' component='m'>
    <bindParam name='p2' value='10s'/>
   </bind>
  </link>
 </body>
</ncl>]])
assert (ncl, errmsg)
assert (filter.apply (ncl))
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
   <bind role='onBegin' component='m'/>
   <bind role='start' component='m'/>
  </link>
 </body>
</ncl>]])))


--  Don't expand the infamous "pega-dali".

local ncl = dietncl.parsestring ([[
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
   <causalConnector id='c2'>
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
   <causalConnector id='c3'>
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
  <link xconnector='c2'>
   <linkParam name='p' value='RED'/>
   <bind role='onSelection' component='x'/>
   <bind role='start' component='z'/>
  </link>
  <link xconnector='c3'>
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'>
    <bindParam name='p' value='$get'/>
   </bind>
   <bind role='start' component='x'/>
  </link>
 </body>
</ncl>]])
assert (ncl)
assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring ([[
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
   <causalConnector id='c2'>
    <compoundCondition operator='and'>
     <compoundCondition operator='and'>
      <compoundCondition operator='and'>
       <simpleCondition role='onSelection' key='RED'/>
      </compoundCondition>
     </compoundCondition>
    </compoundCondition>
    <simpleAction role='start'/>
   </causalConnector>
   <causalConnector id='c3'>
    <connectorParam name="p"/>
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
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'>
    <bindParam name="p" value="$get"/>
   </bind>
   <bind role='start' component='y'/>
  </link>
  <link xconnector='c2'>
   <bind role='onSelection' component='x'/>
   <bind role='start' component='z'/>
  </link>
  <link xconnector='c3'>
   <bind role='get' component='body' interface='p'/>
   <bind role='onSelection' component='x'>
    <bindParam name='p' value='$get'/>
   </bind>
   <bind role='start' component='x'/>
  </link>
 </body>
</ncl>]])))


-- Remove bindParam associated with assessmentStatement
-- TODO

local ncl, errmsg = dietncl.parsestring ([[
<ncl>
<head>
  <connectorBase>
  <causalConnector id='onBeginPropertyTestStart'>
    <connectorParam name='val'/>
    <compoundCondition operator='and'>
      <simpleCondition role='onBegin'/>
      <assessmentStatement comparator='eq'>
        <attributeAssessment role='propertyTest'/>
        <valueAssessment value='$val'/>
      </assessmentStatement>
    </compoundCondition>
    <simpleAction role='start' max='unbounded' qualifier='seq'/>
  </causalConnector>
  </connectorBase>
</head>
<body id='body'>
  <port id='p1' component='m1' />
  <media id='m1' />
  <media id='m2' />
  <media id='noSettings' type='application/x-ginga-settings'>
    <property name='turn' value='x'/>
  </media>
  <link xconnector='onBeginPropertyTestStart' >
    <bind component='m1' role='onBegin'/>
    <bind component='noSettings' interface='turn' role='propertyTest'>
      <bindParam name='val' value='x'/>
    </bind>
    <bind component='m2' role='start'/>
  </link>
</body>
</ncl>]])
assert (ncl, errmsg)
assert (filter.apply (ncl))
print(ncl:str())
assert (ncl:equal (dietncl.parsestring ([[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id="onBeginPropertyTestStart">
        <compoundCondition operator="and">
          <simpleCondition role="onBegin"/>
          <assessmentStatement comparator="eq">
            <attributeAssessment role="propertyTest"/>
            <valueAssessment value="x"/>
          </assessmentStatement>
        </compoundCondition>
        <simpleAction max="unbounded" qualifier="seq" role="start"/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id="body">
    <port id="p1" component="m1"/>
    <media id="m1"/>
    <media id="m2"/>
    <media id="noSettings" type="application/x-ginga-settings">
      <property value="x" name="turn"/>
    </media>
    <link xconnector="onBeginPropertyTestStart">
      <bind component="m1" role="onBegin"/>
      <bind component="noSettings" interface="turn" role="propertyTest"/>
      <bind component="m2" role="start"/>
    </link>
  </body>
</ncl>]])))
