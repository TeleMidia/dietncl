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

local penlight = require ('pl.pretty')
local dietncl = require ('dietncl')
local xml = require ('dietncl.xmlsugar')
local filter = require ('dietncl.filter.smix')

_ENV = nil

-- The penlight is a library used for table printing, just run the below
-- code before this file so it doesnt return errors:
-- # luarocks install penlight


--- add a table that represents the NCL programs so that it is possible
--- to check if the output is correct or not, just by comparing the two



-- NCL program that has the following smix actions:
-- start, set, pause, resume and abort

local str = [[
<ncl id='x'>
  <head>
    <connectorBase>
      <causalConnector id='c1'>
        <compoundCondition operator='and'>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='a' eventType='attribution' attributeType='nodeProperty'/>
            <attributeAssessment role='b' eventType='attribution' attributeType='nodeProperty'/>
          </assessmentStatement>
          <simpleCondition role='onBegin' eventType='presentation' transition='starts'/>
        </compoundCondition>
        <compoundAction>
          <simpleAction role='set' eventType='attribution' actionType='start' value='0.5'/>
          <simpleAction role='pause' eventType='presentation' actionType='pause'/>
        </compoundAction>
      </causalConnector>
      <causalConnector id='c2'>
        <compoundCondition operator='and'>
          <simpleCondition role='onPause' eventType='presentation' transition='pauses'/>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='c' eventType='attribution' attributeType='nodeProperty'/>
            <valueAssessment value='5'/>
          </assessmentStatement>
        </compoundCondition>
        <simpleAction role='resume' eventType='presentation' actionType='resume'/>
      </causalConnector>
      <causalConnector id='c3'>
        <compoundCondition operator='or'>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='i' eventType='attribution' attributeType='nodeProperty'/>
            <valueAssessment value='2'/>
          </assessmentStatement>
          <simpleCondition role='onResume' eventType='presentation' transition='resumes'/>
        </compoundCondition>
        <simpleAction role='abort' eventType='presentation' actionType='abort'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='body'>
    <port id='p1' component='m1'/>
    <port id='p2' component='m2'/>
    <media id='m1' src='m1.png'/>
    <media id='m2' src='m2.png'>
      <property name='taut' value='2'/>
    </media>
    <link id='l1' xconnector='c1'>
      <bind role='onBegin' component='m1'/>
      <bind role='a' component='m2' interface='taut'/>
      <bind role='b' component='m2' interface='taut'/>
      <bind role='set' component='m2' interface='transparency'/>
      <bind role='pause' component='m2'/>
    </link>
    <link id='l2' xconnector='c2'>
      <bind role='onPause' component='m2'/>
      <bind role='resume' component='m2'/>
      <bind role='c' component='m2' interface='taut'/>
    </link>
    <link id='l3' xconnector='c3'>
      <bind role='d' component='m2' interface='taut'/>
      <bind role='onResume' component='m2'/>
      <bind role='abort' component='m1'/>
    </link>
   </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local t = filter.apply (ncl)
assert (t)

print (t)
--penlight.dump (t)



-- NCL program that has the following smix actions:
-- start, set, stop

local str = [[
<ncl id='x'>
  <head>
    <connectorBase>
      <causalConnector id='c1'>
        <compoundCondition operator='and'>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='test' eventType='attribution' attributeType='nodeProperty'/>
            <valueAssessment value='2'/>
          </assessmentStatement>
          <simpleCondition role='onBegin' eventType='presentation' transition='starts'/>
        </compoundCondition>
        <simpleAction role='start' eventType='presentation' actionType='start'/>
      </causalConnector>
      <causalConnector id='c2'>
        <compoundCondition operator='and'>
          <simpleCondition role='onBegin' eventType='presentation' transition='starts'/>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='test' eventType='attribution' attributeType='nodeProperty'/>
            <valueAssessment value='2'/>
          </assessmentStatement>
        </compoundCondition>
        <compoundAction>
          <simpleAction role='set1' eventType='attribution' actionType='start' value='0,5'/>
          <simpleAction role='set2' eventType='attribution' actionType='start' value='0,5'/>
        </compoundAction>
      </causalConnector>
      <causalConnector id='c3'>
        <compoundCondition operator='or'>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='test' eventType='attribution' attributeType='nodeProperty'/>
            <valueAssessment value='2'/>
          </assessmentStatement>
          <simpleCondition role='onEnd' eventType='presentation' transition='stops'/>
        </compoundCondition>
        <compoundAction>
          <simpleAction role='set' eventType='attribution' actionType='start' value='1'/>
          <simpleAction role='start' eventType='presentation' actionType='start'/>
        </compoundAction>
      </causalConnector>
      <causalConnector id='c4'>
        <compoundCondition operator='or'>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='test' eventType='attribution' attributeType='nodeProperty'/>
            <valueAssessment value='2'/>
          </assessmentStatement>
          <simpleCondition role='onEnd' eventType='presentation' transition='stops'/>
        </compoundCondition>
        <simpleAction role='stop' eventType='presentation' actionType='stop'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='body'>
    <port id='p1' component='m1'/>
    <media id='m1' src='m1.png'/>
    <media id='m2' src='m2.png'>
      <property name='taut' value='2'/>
    </media>
    <media id='m3' src='m3.png'/>
    <link id='l1' xconnector='c1'>
      <bind role='onBegin' component='m1'/>
      <bind role='test' component='m2' interface='taut'/>
      <bind role='start' component='m2'/>
    </link>
    <link id='l2' xconnector='c2'>
      <bind role='onBegin' component='m2'/>
      <bind role='set1' component='m1' interface='width'/>
      <bind role='set2' component='m2' interface='width'/>
      <bind role='test' component='m2' interface='taut'/>
    </link>
    <link id='l3' xconnector='c3'>
      <bind role='test' component='m2' interface='taut'/>
      <bind role='onEnd' component='m2'/>
      <bind role='set' component='m1' interface='width'/>
      <bind role='start' component='m3'/>
    </link>
    <link id='l4' xconnector='c4'>
      <bind role='test' component='m2' interface='taut'/>
      <bind role='onEnd' component='m3'/>
      <bind role='stop' component='m1'/>
    </link>
   </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local t = filter.apply (ncl)
assert (t)

print (t)
--penlight.dump (t)

--- there is no way of properly testing them though
print ('both tests seem to be working just fine, '..
          'uncomment penlight.dump to check output table')
