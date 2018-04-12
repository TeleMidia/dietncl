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
local print = print

local dietncl = require ('dietncl')
local filter = require ('dietncl.filter.prenorm5')
local xml = require ('dietncl.xmlsugar')

_ENV = nil

-- Test the case of two compound elements, each containing two simple child elements.

local ncl = dietncl.parsestring([[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c'>
        <compoundCondition operator='and'>
          <simpleCondition role='onBegin'/>
          <simpleCondition role='onEnd'/>
        </compoundCondition>
        <simpleAction role='start'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='body'>
    <media id='m'/>
    <link xconnector='c'>
      <bind role='onBegin' component='m'/>
      <bind role='onEnd' component='m'/>
      <bind role='start' component='m'/>
    </link>
  </body>
</ncl>
]])

local str = dietncl.parsestring([[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id="c">
        <compoundCondition operator="and">
          <compoundCondition operator="and">
            <simpleCondition role="onBegin" />
            <assessmentStatement comparator="eq">
              <attributeAssessment role="_____0" eventType="attribution" />
              <attributeAssessment role="_____1" eventType="attribution" />
            </assessmentStatement>
          </compoundCondition>
          <compoundCondition operator="and">
            <simpleCondition role="onEnd" />
            <assessmentStatement comparator="eq">
              <attributeAssessment role="_____3" eventType="attribution" />
              <attributeAssessment role="_____4" eventType="attribution" />
            </assessmentStatement>
          </compoundCondition>
          <assessmentStatement comparator="eq">
            <attributeAssessment role="_____5" eventType="attribution" />
            <attributeAssessment role="_____6" eventType="attribution" />
          </assessmentStatement>
        </compoundCondition>
        <simpleAction role='start'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id="body">
    <media id="m" />
    <link xconnector="c">
      <bind role="onBegin" component="m" />
      <bind role="onEnd" component="m" />
      <bind role="start" component="m" />
      <bind role="_____0" interface="_____2" component="body"/>
      <bind role="_____1" interface="_____2" component="body"/>
      <bind role="_____3" interface="_____2" component="body"/>
      <bind role="_____4" interface="_____2" component="body"/>
      <bind role="_____5" interface="_____2" component="body"/>
      <bind role="_____6" interface="_____2" component="body"/>
    </link>
    <property name="_____2" />
  </body>
</ncl>
]])

assert (filter.apply (ncl))
assert (ncl:equal (str))

local str = [[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c'>
        <compoundCondition operator='and'>
          <simpleCondition role='onBegin' delay='5s'/>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='R1'/>
            <attributeAssessment role='R2'/>
          </assessmentStatement>
        </compoundCondition >
        <simpleAction role='start' delay='15s'/>
      </causalConnector>
    </connectorBase>
  </head>

  <body>
    <context id='bubble'>
      <media id='m'/>
      <property name='value'/>
      <link xconnector='c'>
        <bind role='onBegin' component='m'/>
        <bind role='start' component='m'/>
        <bind role='R1' component='bubble' interface='value'/>
        <bind role='R2' component='bubble' interface='value'/>
        <bind role='R3' component='bubble' interface='value'/>
        <bind role='R4' component='bubble' interface='value'/>
      </link>
    </context>
  </body>
</ncl>
]]

local ncl = assert (dietncl.parsestring (str))
assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring(str)))

-- Test for a NCL document which contains more than one causalConnectors.

local ncl = dietncl.parsestring ([[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c'>
        <compoundCondition operator='and'>
          <compoundCondition operator='and'>
            <simpleCondition role='onBegin' delay='5s'/>
            <simpleCondition role='onEnd'/>
          </compoundCondition>
        </compoundCondition >
        <compoundAction operator='and'>
          <compoundAction operator='and'>
            <simpleAction role='start' delay='15s'/>
            <simpleAction role='pause'/>
          </compoundAction>
        </compoundAction>
      </causalConnector>

      <causalConnector id='a'>
        <compoundCondition operator='or'>
          <compoundCondition operator='and'>
            <simpleCondition role='onBegin' delay='15s'/>
            <simpleCondition role='onSelection'/>
          </compoundCondition>
        </compoundCondition>
        <simpleAction role='start'/>
      </causalConnector>
    </connectorBase>
  </head>

  <body>
    <media id='n'/>
    <media id='o'/>
    <media id='p'/>
    <media id='s'/>

    <context id='bubble'>
      <media id='m'/>
      <media id='w'/>
      <port id='first' component='w'/>

      <link xconnector='c'>
        <bind role='onBegin' component='m'/>
        <bind role='onEnd' component='w'/>
        <bind role='start' component='w'/>
        <bind role='pause' component='m'/>
      </link>
    </context>

    <link xconnector='a'>
      <bind role='onBegin' component='o'/>
      <bind role='onSelection' component='n'/>
      <bind role='start' component='p'/>
    </link>
  </body>
</ncl>
]])

local str =  [[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id="c">
        <compoundCondition operator="and">
          <compoundCondition operator="and">
            <simpleCondition role="onBegin" delay="5s" />
            <assessmentStatement comparator="eq">
              <attributeAssessment role="_______0" eventType="attribution" />
              <attributeAssessment role="_______1" eventType="attribution" />
            </assessmentStatement>
          </compoundCondition>
          <compoundCondition operator="and">
            <simpleCondition role="onEnd" />
            <assessmentStatement comparator="eq">
              <attributeAssessment role="_______3" eventType="attribution" />
              <attributeAssessment role="_______4" eventType="attribution" />
            </assessmentStatement>
          </compoundCondition>
          <assessmentStatement comparator="eq">
            <attributeAssessment role="_______5" eventType="attribution" />
            <attributeAssessment role="_______6" eventType="attribution" />
          </assessmentStatement>
        </compoundCondition>
        <compoundAction operator="and">
          <simpleAction role="start" delay="15s" />
          <simpleAction role="pause" />
        </compoundAction>
      </causalConnector>
      <causalConnector id="a">
        <simpleAction role="start"/>
        <compoundCondition operator="and">
          <compoundCondition operator="and">
            <simpleCondition role="onBegin" delay="15s" />
            <assessmentStatement comparator="eq">
              <attributeAssessment role="_______7" eventType="attribution" />
              <attributeAssessment role="_______8" eventType="attribution" />
            </assessmentStatement>
          </compoundCondition>
          <compoundCondition operator="and">
            <simpleCondition role="onSelection" />
            <assessmentStatement comparator="eq">
              <attributeAssessment role="_______10" eventType="attribution" />
              <attributeAssessment role="_______11" eventType="attribution" />
            </assessmentStatement>
          </compoundCondition>
          <assessmentStatement comparator="eq">
            <attributeAssessment role="_______13" eventType="attribution" />
            <attributeAssessment role="_______14" eventType="attribution" />
          </assessmentStatement>
        </compoundCondition>
      </causalConnector>
    </connectorBase>
  </head>
  <body>
    <media id="n" />
    <media id="o" />
    <media id="p" />
    <media id="s" />
    <context id="bubble">
      <media id="m" />
      <media id="w" />
      <port id="first" component="w" />
      <link xconnector="c">
        <bind role="onBegin" component="m" />
        <bind role="onEnd" component="w" />
        <bind role="start" component="w" />
        <bind role="pause" component="m" />
        <bind component="bubble" role="_______0" interface="_______2" />
        <bind component="bubble" role="_______1" interface="_______2" />
        <bind component="bubble" role="_______3" interface="_______2" />
        <bind component="bubble" role="_______4" interface="_______2" />
        <bind component="bubble" role="_______5" interface="_______2" />
        <bind component="bubble" role="_______6" interface="_______2" />
      </link>
      <property name="_______2" />
    </context>
    <link xconnector="a">
      <bind role="onBegin" component="o" />
      <bind role="onSelection" component="n" />
      <bind role="start" component="p" />
      <bind role="_______7" interface="_______9" />
      <bind role="_______8" interface="_______9" />
      <bind role="_______10" interface="_______12" />
      <bind role="_______11" interface="_______12" />
      <bind role="_______13" interface="_______15" />
      <bind role="_______14" interface="_______15" />
    </link>
    <property name="_______9" />
    <property name="_______12" />
    <property name="_______15" />
  </body>
</ncl>]]

assert(filter.apply(ncl))
assert(ncl:equal (dietncl.parsestring(str)))

-- Make sure the filter does not change the NCL document out of need.

local str = [[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c'>
        <compoundCondition operator='and'>
          <compoundCondition operator='and'>
            <compoundCondition operator='and'>
              <simpleCondition role='onBegin'/>
              <assessmentStatement comparator='eq'>
                <attributeAssessment role='i' eventType='attribution'/>
                <attributeAssessment role='j' eventType='attribution'/>
              </assessmentStatement>
            </compoundCondition>
            <compoundCondition operator='and'>
              <simpleCondition role='onResume'/>
              <assessmentStatement comparator='eq'>
                <attributeAssessment role='k' eventType='attribution'/>
                <attributeAssessment role='l' eventType='attribution'/>
              </assessmentStatement>
            </compoundCondition>
            <assessmentStatement comparator='eq'>
              <attributeAssessment role='a' eventType='attribution'/>
              <attributeAssessment role='b' eventType='attribution'/>
            </assessmentStatement>
          </compoundCondition>
          <compoundCondition operator='and'>
            <compoundCondition operator='and'>
              <simpleCondition role='onEnd'/>
              <assessmentStatement comparator='eq'>
                <attributeAssessment role='e' eventType='attribution'/>
                <attributeAssessment role='f' eventType='attribution'/>
              </assessmentStatement>
            </compoundCondition>
            <compoundCondition operator='and'>
              <simpleCondition role='onAbort'/>
              <assessmentStatement comparator='eq'>
                <attributeAssessment role='g' eventType='attribution'/>
                <attributeAssessment role='h' eventType='attribution'/>
              </assessmentStatement>
            </compoundCondition>
            <assessmentStatement comparator='eq'>
              <attributeAssessment role='c' eventType='attribution'/>
              <attributeAssessment role='d' eventType='attribution'/>
            </assessmentStatement>
          </compoundCondition>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='r' eventType='attribution'/>
            <attributeAssessment role='s' eventType='attribution'/>
          </assessmentStatement>
        </compoundCondition>
        <simpleAction role="start"/>
      </causalConnector>
    </connectorBase>
  </head>

  <body id='body'>
    <media id='m'/>
    <property name='value'/>
    <link xconnector='c'>
      <bind role='onBegin' component='m'/>
      <bind role='onResume' component='m'/>
      <bind role='start' component='m'/>
      <bind role='a' interface='value' component='body'/>
      <bind role='b' interface='value' component='body'/>
      <bind role='i' interface='value' component='body'/>
      <bind role='j' interface='value' component='body'/>
      <bind role='k' interface='value' component='body'/>
      <bind role='l' interface='value' component='body'/>
      <bind role='onEnd' component='m'/>
      <bind role='onAbort' component='m'/>
      <bind role='c' interface='value' component='body'/>
      <bind role='d' interface='value' component='body'/>
      <bind role='e' interface='value' component='body'/>
      <bind role='f' interface='value' component='body'/>
      <bind role='g' interface='value' component='body'/>
      <bind role='h' interface='value' component='body'/>
      <bind role='r' interface='value' component='body'/>
      <bind role='s' interface='value' component='body'/>
    </link>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring (str)))

-- -- Apply filter on a more robust NCL document.

-- local ncl = assert (dietncl.parsestring ([[
-- <ncl>
--     <head>
--         <connectorBase>
--             <causalConnector id='c'>
--                 <compoundCondition operator='or'>
--                     <compoundCondition operator='and'>
--                         <simpleCondition role='onBegin' delay='5s'/>
--                         <simpleCondition role='onSelection' key='ENTER'/>
--                         <simpleCondition role='onEnd'/>
--                         <simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
--                     </compoundCondition>
--                     <compoundCondition operator='and'>
--                         <simpleCondition role='onResume'/>
--                         <simpleCondition role='onPause'/>
--                         <compoundStatement operator='and'>
--                             <assessmentStatement comparator='ne'>
--                                 <attributeAssessment role='R17' eventType='attribution'/>
--                                 <attributeAssessment role='R18' eventType='attribution'/>
--                             </assessmentStatement>
--                             <assessmentStatement comparator='ne'>
--                                 <attributeAssessment role='R19' eventType='attribution'/>
--                                 <attributeAssessment role='R20' eventType='attribution'/>
--                             </assessmentStatement>
--                         </compoundStatement>
--                     </compoundCondition>
--                     <compoundCondition operator='and'>
--                         <simpleCondition role='beginning' transition='presentation' eventType='presentation'/>
--                         <assessmentStatement comparator='ne'>
--                             <attributeAssessment role='R1' eventType='attribution'/>
--                             <attributeAssessment role='R2' eventType='attribution'/>
--                         </assessmentStatement>
--                     </compoundCondition>
--                 </compoundCondition>
--                 <compoundAction operator='par'>
--                     <compoundAction operator='seq'>
--                         <simpleAction role='start'/>
--                         <simpleAction role='pause'/>
--                         <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R3' eventType='attribution'/>
--                             <attributeAssessment role='R4' eventType='attribution'/>
--                         </assessmentStatement>
--                     </compoundAction>
--                     <compoundAction operator='par'>
--                         <simpleAction role='abort'/>
--                         <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R9' eventType='attribution'/>
--                             <attributeAssessment role='R10' eventType='attribution'/>
--                         </assessmentStatement>
--                     </compoundAction>
--                     <compoundAction operator='seq'>
--                         <simpleAction role='resume'/>
--                         <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R11' eventType='attribution'/>
--                             <attributeAssessment role='R12' eventType='attribution'/>
--                         </assessmentStatement>
--                     </compoundAction>
--                 </compoundAction>
--                 <compoundStatement operator='and'>
--                     <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R13' eventType='attribution'/>
--                             <attributeAssessment role='R14' eventType='attribution'/>
--                     </assessmentStatement>
--                     <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R15' eventType='attribution'/>
--                             <attributeAssessment role='R16' eventType='attribution'/>
--                     </assessmentStatement>
--                 </compoundStatement>
--             </causalConnector>

--             <causalConnector id='a'>
--                 <compoundCondition operator='or'>
--                     <compoundCondition operator='and'>
--                         <simpleCondition role='onBegin' delay='15s'/>
--                         <simpleCondition role='onSelection'/>
--                         <simpleCondition role='onBeginSelect' key='ENTER' transition='starts' eventType='selection'/>
--                         <simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
--                         <simpleCondition role='start_again' eventType='presentation' transition='presentation'/>
--                         <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R5' eventType='attribution'/>
--                             <attributeAssessment role='R6' eventType='attribution'/>
--                         </assessmentStatement>
--                     </compoundCondition>
--                     <compoundCondition operator='and'>
--                         <simpleCondition role='onResume'/>
--                         <assessmentStatement comparator='eq'>
--                             <attributeAssessment role='R7' eventType='attribution'/>
--                             <attributeAssessment role='R8' eventType='attribution'/>
--                         </assessmentStatement>
--                     </compoundCondition>
--                 </compoundCondition>
--                 <simpleAction role='start'/>
--                 <assessmentStatement comparator='ne'>
--                         <attributeAssessment role='R21' eventType='attribution'/>
--                         <attributeAssessment role='R22' eventType='attribution'/>
--                 </assessmentStatement>
--             </causalConnector>
--         </connectorBase>
--     </head>

--     <body>
--         <property name='master_value'/>

--         <media id='m'/>
--         <media id='n'/>
--         <media id='o'/>
--         <media id='p'/>
--         <media id='s'/>

--         <context id='bubble_one'>
--             <property name='value'/>
--             <property name='another_value'/>
--             <media id='w'/>
--             <port id='first' component='w'/>

--             <link xconnector='c'>
--                 <bind role='onBegin' component='m'/>
--                 <bind role='onSelection' component='n'>
--                     <bindParam name='key' value='ENTER'/>
--                 </bind>
--                 <bind role='onEnd' component='o'/>
--                 <bind role='onResume' component='w'/>
--                 <bind role='onPause' component='n'/>
--                 <bind role='beginning' component='m'/>
--                 <bind role='start' comnponent='n'/>
--                 <bind role='pause' component='m'/>
--                 <bind role='abort' component='w'/>
--                 <bind role='resume' component='n'/>
--                 <bind role='R1' component='value'/>
--                 <bind role='R2' component='another_value'/>
--                 <bind role='R3' component='value'/>
--                 <bind role='R4' component='value'/>
--                 <bind role='R9' component='value'/>
--                 <bind role='R10' component='value'/>
--                 <bind role='R11' component='value'/>
--                 <bind role='R12' component='value'/>
--                 <bind role='R13' component='value'/>
--                 <bind role='R14' component='value'/>
--                 <bind role='R17' component='value'/>
--                 <bind role='R18' component='value'/>
--                 <bind role='R19' component='value'/>
--                 <bind role='R20' component='value'/>
--             </link>
--         </context>

--         <link xconnector='a'>
--             <bind role='onBegin' component='o'/>
--             <bind role='onSelection' component='n'/>
--             <bind role='onResume' component='m'/>
--             <bind role='onBeginSelect' component='p'>
--                 <bindParam name='key' value='ENTER'/>
--             </bind>
--             <bind role='onResume' component='s'/>
--             <bind role='start' component='n'/>
--             <bind role='R5' component='master_value'/>
--             <bind role='R6' component='master_value'/>
--             <bind role='R7' component='master_value'/>
--             <bind role='R8' component='master_value'/>
--             <bind role='R21' component='master_value'/>
--             <bind role='R22' component='master_value'/>
--             <bind role='onAbort' component='m'/>
--             <bind role='start_again' component='s'/>
--             <bind role='start' component='m'/>
--         </link>
--     </body>
-- </ncl>]]))

-- local str = [[
-- <ncl>
--     <head>
--         <connectorBase>
--                 <causalConnector id="c">
--                         <compoundCondition operator="or">
--                                 <compoundCondition operator="and">
--                                         <compoundStatement operator="and">
--                                                 <assessmentStatement comparator="ne">
--                                                         <attributeAssessment role="R17" eventType="attribution" />
--                                                         <attributeAssessment role="R18" eventType="attribution" />
--                                                 </assessmentStatement>
--                                                 <assessmentStatement comparator="ne">
--                                                         <attributeAssessment role="R19" eventType="attribution" />
--                                                         <attributeAssessment role="R20" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundStatement>
--                                         <compoundCondition operator="and">
--                                                 <simpleCondition role="onResume" />
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="___________8" eventType="attribution" />
--                                                         <attributeAssessment role="___________9" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundCondition>
--                                         <compoundCondition operator="and">
--                                                 <simpleCondition role="onPause" />
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="___________10" eventType="attribution" />
--                                                         <attributeAssessment role="___________11" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundCondition>
--                                 </compoundCondition>
--                                 <compoundCondition operator="or">
--                                         <compoundCondition operator="and">
--                                                 <compoundCondition operator="and">
--                                                         <simpleCondition transition="aborts" eventType="presentation" role="onAbort" />
--                                                         <assessmentStatement comparator="eq">
--                                                                 <attributeAssessment role="___________6" eventType="attribution" />
--                                                                 <attributeAssessment role="___________7" eventType="attribution" />
--                                                         </assessmentStatement>
--                                                 </compoundCondition>
--                                                 <compoundCondition operator="and">
--                                                         <compoundCondition operator="and">
--                                                                 <simpleCondition role="onSelection" key="ENTER" />
--                                                                 <assessmentStatement comparator="eq">
--                                                                         <attributeAssessment role="___________2" eventType="attribution" />
--                                                                         <attributeAssessment role="___________3" eventType="attribution" />
--                                                                 </assessmentStatement>
--                                                         </compoundCondition>
--                                                         <compoundCondition operator="and">
--                                                                 <compoundCondition operator="and">
--                                                                         <simpleCondition role="onBegin" delay="5s" />
--                                                                         <assessmentStatement comparator="eq">
--                                                                                 <attributeAssessment role="___________0" eventType="attribution" />
--                                                                                 <attributeAssessment role="___________1" eventType="attribution" />
--                                                                         </assessmentStatement>
--                                                                 </compoundCondition>
--                                                                 <compoundCondition operator="and">
--                                                                         <simpleCondition role="onEnd" />
--                                                                         <assessmentStatement comparator="eq">
--                                                                                 <attributeAssessment role="___________4" eventType="attribution" />
--                                                                                 <attributeAssessment role="___________5" eventType="attribution" />
--                                                                         </assessmentStatement>
--                                                                 </compoundCondition>
--                                                                 <assessmentStatement comparator="eq">
--                                                                         <attributeAssessment role="___________20" eventType="attribution" />
--                                                                         <attributeAssessment role="___________21" eventType="attribution" />
--                                                                 </assessmentStatement>
--                                                         </compoundCondition>
--                                                         <assessmentStatement comparator="eq">
--                                                                 <attributeAssessment role="___________18" eventType="attribution" />
--                                                                 <attributeAssessment role="___________19" eventType="attribution" />
--                                                         </assessmentStatement>
--                                                 </compoundCondition>
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="___________16" eventType="attribution" />
--                                                         <attributeAssessment role="___________17" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundCondition>
--                                         <compoundCondition operator="and">
--                                                 <simpleCondition transition="presentation" eventType="presentation" role="beginning" />
--                                                 <assessmentStatement comparator="ne">
--                                                         <attributeAssessment role="R1" eventType="attribution" />
--                                                         <attributeAssessment role="R2" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundCondition>
--                                         <assessmentStatement comparator="eq">
--                                                 <attributeAssessment role="___________14" eventType="attribution" />
--                                                 <attributeAssessment role="___________15" eventType="attribution" />
--                                         </assessmentStatement>
--                                 </compoundCondition>
--                                 <assessmentStatement comparator="eq">
--                                         <attributeAssessment role="___________12" eventType="attribution" />
--                                         <attributeAssessment role="___________13" eventType="attribution" />
--                                 </assessmentStatement>
--                         </compoundCondition>
--                         <compoundAction operator="par">
--                                 <compoundAction operator="par">
--                                         <simpleAction role="abort" />
--                                         <assessmentStatement comparator="eq">
--                                                 <attributeAssessment role="R9" eventType="attribution" />
--                                                 <attributeAssessment role="R10" eventType="attribution" />
--                                         </assessmentStatement>
--                                 </compoundAction>
--                                 <compoundAction operator="par">
--                                         <compoundAction operator="seq">
--                                                 <simpleAction role="start" />
--                                                 <simpleAction role="pause" />
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="R3" eventType="attribution" />
--                                                         <attributeAssessment role="R4" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundAction>
--                                         <compoundAction operator="seq">
--                                                 <simpleAction role="resume" />
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="R11" eventType="attribution" />
--                                                         <attributeAssessment role="R12" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundAction>
--                                         <assessmentStatement comparator="eq">
--                                                 <attributeAssessment role="___________24" eventType="attribution" />
--                                                 <attributeAssessment role="___________25" eventType="attribution" />
--                                         </assessmentStatement>
--                                 </compoundAction>
--                                 <assessmentStatement comparator="eq">
--                                         <attributeAssessment role="___________22" eventType="attribution" />
--                                         <attributeAssessment role="___________23" eventType="attribution" />
--                                 </assessmentStatement>
--                         </compoundAction>
--                         <compoundStatement operator="and">
--                                 <assessmentStatement comparator="eq">
--                                         <attributeAssessment role="R13" eventType="attribution" />
--                                         <attributeAssessment role="R14" eventType="attribution" />
--                                 </assessmentStatement>
--                                 <assessmentStatement comparator="eq">
--                                         <attributeAssessment role="R15" eventType="attribution" />
--                                         <attributeAssessment role="R16" eventType="attribution" />
--                                 </assessmentStatement>
--                         </compoundStatement>
--                 </causalConnector>
--                 <causalConnector id="a">
--                         <compoundCondition operator="or">
--                                 <compoundCondition operator="and">
--                                         <compoundCondition operator="and">
--                                                 <compoundCondition operator="and">
--                                                         <simpleCondition role="onSelection" />
--                                                         <assessmentStatement comparator="eq">
--                                                                 <attributeAssessment role="___________28" eventType="attribution" />
--                                                                 <attributeAssessment role="___________29" eventType="attribution" />
--                                                         </assessmentStatement>
--                                                 </compoundCondition>
--                                                 <compoundCondition operator="and">
--                                                         <simpleCondition transition="aborts" eventType="presentation" role="onAbort" />
--                                                         <assessmentStatement comparator="eq">
--                                                                 <attributeAssessment role="___________32" eventType="attribution" />
--                                                                 <attributeAssessment role="___________33" eventType="attribution" />
--                                                         </assessmentStatement>
--                                                 </compoundCondition>
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="___________40" eventType="attribution" />
--                                                         <attributeAssessment role="___________41" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundCondition>
--                                         <compoundCondition operator="and">
--                                                 <compoundCondition operator="and">
--                                                         <simpleCondition transition="starts" key="ENTER" eventType="selection" role="onBeginSelect" />
--                                                         <assessmentStatement comparator="eq">
--                                                                 <attributeAssessment role="___________30" eventType="attribution" />
--                                                                 <attributeAssessment role="___________31" eventType="attribution" />
--                                                         </assessmentStatement>
--                                                 </compoundCondition>
--                                                 <compoundCondition operator="and">
--                                                         <compoundCondition operator="and">
--                                                                 <simpleCondition role="onBegin" delay="15s" />
--                                                                 <assessmentStatement comparator="eq">
--                                                                         <attributeAssessment role="___________26" eventType="attribution" />
--                                                                         <attributeAssessment role="___________27" eventType="attribution" />
--                                                                 </assessmentStatement>
--                                                         </compoundCondition>
--                                                         <compoundCondition operator="and">
--                                                                 <simpleCondition transition="presentation" eventType="presentation" role="start_again" />
--                                                                 <assessmentStatement comparator="eq">
--                                                                         <attributeAssessment role="___________34" eventType="attribution" />
--                                                                         <attributeAssessment role="___________35" eventType="attribution" />
--                                                                 </assessmentStatement>
--                                                         </compoundCondition>
--                                                         <assessmentStatement comparator="eq">
--                                                                 <attributeAssessment role="___________44" eventType="attribution" />
--                                                                 <attributeAssessment role="___________45" eventType="attribution" />
--                                                         </assessmentStatement>
--                                                 </compoundCondition>
--                                                 <assessmentStatement comparator="eq">
--                                                         <attributeAssessment role="___________42" eventType="attribution" />
--                                                         <attributeAssessment role="___________43" eventType="attribution" />
--                                                 </assessmentStatement>
--                                         </compoundCondition>
--                                         <assessmentStatement comparator="eq">
--                                                 <attributeAssessment role="___________38" eventType="attribution" />
--                                                 <attributeAssessment role="___________39" eventType="attribution" />
--                                         </assessmentStatement>
--                                 </compoundCondition>
--                                 <compoundCondition operator="and">
--                                         <simpleCondition role="onResume" />
--                                         <assessmentStatement comparator="eq">
--                                                 <attributeAssessment role="R7" eventType="attribution" />
--                                                 <attributeAssessment role="R8" eventType="attribution" />
--                                         </assessmentStatement>
--                                 </compoundCondition>
--                                 <assessmentStatement comparator="eq">
--                                         <attributeAssessment role="___________36" eventType="attribution" />
--                                         <attributeAssessment role="___________37" eventType="attribution" />
--                                 </assessmentStatement>
--                         </compoundCondition>
--                         <simpleAction role="start" />
--                         <assessmentStatement comparator="ne">
--                                 <attributeAssessment role="R21" eventType="attribution" />
--                                 <attributeAssessment  role="R22" eventType="attribution" />
--                         </assessmentStatement>
--                 </causalConnector>
--         </connectorBase>
--     </head>
--     <body>
--         <property name="master_value" />
--         <media id="m" />
--         <media id="n" />
--         <media id="o" />
--         <media id="p" />
--         <media id="s" />
--         <context id="bubble_one">
--                 <property name="value" />
--                 <property name="another_value" />
--                 <media id="w" />
--                 <port id="first" component="w" />
--                 <link xconnector="c">
--                         <bind role="onBegin" component="m" />
--                         <bind component="n" role="onSelection">
--                                 <bindParam name="key" value="ENTER" />
--                         </bind>
--                         <bind role="onEnd" component="o" />
--                         <bind role="onResume" component="w" />
--                         <bind role="onPause" component="n" />
--                         <bind role="beginning" component="m" />
--                         <bind role="start" comnponent="n" />
--                         <bind role="pause" component="m" />
--                         <bind role="abort" component="w" />
--                         <bind role="resume" component="n" />
--                         <bind role="R1" component="value" />
--                         <bind role="R2" component="another_value" />
--                         <bind role="R3" component="value" />
--                         <bind role="R4" component="value" />
--                         <bind role="R9" component="value" />
--                         <bind role="R10" component="value" />
--                         <bind role="R11" component="value" />
--                         <bind role="R12" component="value" />
--                         <bind role="R13" component="value" />
--                         <bind role="R14" component="value" />
--                         <bind role="R17" component="value" />
--                         <bind role="R18" component="value" />
--                         <bind role="R19" component="value" />
--                         <bind role="R20" component="value" />
--                         <bind component="bubble_one" role="___________0" interface="value" />
--                         <bind component="bubble_one" role="___________1" interface="value" />
--                         <bind component="bubble_one" role="___________2" interface="value" />
--                         <bind component="bubble_one" role="___________3" interface="value" />
--                         <bind component="bubble_one" role="___________4" interface="value" />
--                         <bind component="bubble_one" role="___________5" interface="value" />
--                         <bind component="bubble_one" role="___________6" interface="value" />
--                         <bind component="bubble_one" role="___________7" interface="value" />
--                         <bind component="bubble_one" role="___________8" interface="value" />
--                         <bind component="bubble_one" role="___________9" interface="value" />
--                         <bind component="bubble_one" role="___________10" interface="value" />
--                         <bind component="bubble_one" role="___________11" interface="value" />
--                         <bind component="bubble_one" role="___________12" interface="value" />
--                         <bind component="bubble_one" role="___________13" interface="value" />
--                         <bind component="bubble_one" role="___________14" interface="value" />
--                         <bind component="bubble_one" role="___________15" interface="value" />
--                         <bind component="bubble_one" role="___________16" interface="value" />
--                         <bind component="bubble_one" role="___________17" interface="value" />
--                         <bind component="bubble_one" role="___________18" interface="value" />
--                         <bind component="bubble_one" role="___________19" interface="value" />
--                         <bind component="bubble_one" role="___________20" interface="value" />
--                         <bind component="bubble_one" role="___________21" interface="value" />
--                         <bind component="bubble_one" role="___________22" interface="value" />
--                         <bind component="bubble_one" role="___________23" interface="value" />
--                         <bind component="bubble_one" role="___________24" interface="value" />
--                         <bind component="bubble_one" role="___________25" interface="value" />
--                 </link>
--         </context>
--         <link xconnector="a">
--                 <bind role="onBegin" component="o" />
--                 <bind role="onSelection" component="n" />
--                 <bind role="onResume" component="m" />
--                 <bind role="onBeginSelect" component="p">
--                         <bindParam name="key" value="ENTER" />
--                         <bind role="onResume" component="s" />
--                         <bind role="start" component="n" />
--                         <bind role="R5" component="master_value" />
--                         <bind role="R6" component="master_value" />
--                         <bind role="R7" component="master_value" />
--                         <bind role="R8" component="master_value" />
--                         <bind role="R21" component="master_value" />
--                         <bind role="R22" component="master_value" />
--                         <bind role="onAbort" component="m" />
--                         <bind role="start_again" component="s" />
--                         <bind role="start" component="m" />
--                 </bind>
--                 <bind role="___________26" interface="master_value" />
--                 <bind role="___________27" interface="master_value" />
--                 <bind role="___________28" interface="master_value" />
--                 <bind role="___________29" interface="master_value" />
--                 <bind role="___________30" interface="master_value" />
--                 <bind role="___________31" interface="master_value" />
--                 <bind role="___________32" interface="master_value" />
--                 <bind role="___________33" interface="master_value" />
--                 <bind role="___________34" interface="master_value" />
--                 <bind role="___________35" interface="master_value" />
--                 <bind role="___________36" interface="master_value" />
--                 <bind role="___________37" interface="master_value" />
--                 <bind role="___________38" interface="master_value" />
--                 <bind role="___________39" interface="master_value" />
--                 <bind role="___________40" interface="master_value" />
--                 <bind role="___________41" interface="master_value" />
--                 <bind role="___________42" interface="master_value" />
--                 <bind role="___________43" interface="master_value" />
--                 <bind role="___________44" interface="master_value" />
--                 <bind role="___________45" interface="master_value" />
--         </link>
--     </body>
-- </ncl>]]
-- assert (ncl)
-- assert(filter.apply(ncl))
-- assert(ncl:equal (dietncl.parsestring(str)))
