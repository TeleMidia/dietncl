--[[ Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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
local filter = require ('dietncl.filter.norm1')

_ENV = nil

-- First test makes sure that the function does not alter code that is already in the correct form.

local str = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="__0">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__1">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <property name="__2" />
                <link xconnector="__0">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>

                <context id="vortex">
                    <property name="__9">
                    <link xconnector="__1">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__9" />
                        <bind role="__1" interface="__9" />
                        <bind role="__3" interface="__9" />
                        <bind role="__4" interface="__9" />
                        <bind role="__5" interface="__9" />
                        <bind role="__6" interface="__9" />
                        <bind role="__7" interface="__9" />
                        <bind role="__8" interface="__9" />
                    </link>
                </context>

        </body>
</ncl>]])

local ncl = str
assert (filter.apply (ncl))
assert (ncl:equal (str))

-- Makes sure two connectors are created, one for each compoundCondition inside compoundCondition which presents OR operator.

local ncl = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="or">
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onBegin" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onEnd" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__5" eventType="attribution" />
                                                <attributeStatement role="__6" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="start" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="__7" eventType="attribution" />
                                    <attributeStatement role="__8" eventType="attribution" />
                                </assessmentStatement>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
                <property name="__2" />
        </body>
</ncl>]])

local str = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="__01">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__11">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <property name="__2" />
                <link xconnector="__01">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
                <link xconnector="__11">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
        </body>
</ncl>]])

assert (filter.apply (ncl))
assert (ncl:equal (str))

-- One more test for a NCL document which has more extensive connectors.

local ncl = dietncl.parsestring([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="or">
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onBegin" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onEnd" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__5" eventType="attribution" />
                                                <attributeStatement role="__6" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="start" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="a">
                                <compoundCondition operator="or">
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onPause" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onAbort" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__11" eventType="attribution" />
                                                <attributeStatement role="__12" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="start" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                </link>
                <link xconnector="a">
                    <bind role="onPause" component="m" />
                    <bind role="onAbort" component="m" />
                    <bind role="start" component="m" />
                    <bind role="pause" component="m" />
                    <bind role="__7" interface="__2" />
                    <bind role="__8" interface="__2" />
                    <bind role="__9" interface="__2" />
                    <bind role="__10" interface="__2" />
                    <bind role="__11" interface="__2" />
                    <bind role="__12" interface="__2" />
                </link>
                <property name="__2" />
        </body>
</ncl>]])

local str = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="__01">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__11">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__21">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onPause" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__11" eventType="attribution" />
                                                        <attributeStatement role="__12" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__31">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onAbort" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__11" eventType="attribution" />
                                                        <attributeStatement role="__12" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <property name="__2" />
                <link xconnector="__01">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                </link>
                <link xconnector="__11">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                </link>
                <link xconnector="__21">
                        <bind role="onPause" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                        <bind role="__11" interface="__2" />
                        <bind role="__12" interface="__2" />
                </link>
                <link xconnector="__31">
                        <bind role="onAbort" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__9" interface="__2" />
                        <bind role="__10" interface="__2" />
                        <bind role="__11" interface="__2" />
                        <bind role="__12" interface="__2" />
                </link>
        </body>
</ncl>]])

assert (filter.apply (ncl))
assert (ncl:equal (str))

-- Another test for compoundConditions which present OR operator, this time one link being the child of a context.

local ncl = dietncl.parsestring([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="or">
                                        <compoundCondition operator="or">
                                            <compoundCondition operator="and">
                                                    <simpleCondition role="onBegin" />
                                                    <assessmentStatement comparator="eq">
                                                            <attributeStatement role="__0" eventType="attribution" />
                                                            <attributeStatement role="__1" eventType="attribution" />
                                                    </assessmentStatement>
                                            </compoundCondition>
                                            <compoundCondition operator="and">
                                                    <simpleCondition role="onResume" />
                                                    <assessmentStatement comparator="eq">
                                                            <attributeStatement role="__13" eventType="attribution" />
                                                            <attributeStatement role="__14" eventType="attribution" />
                                                    </assessmentStatement>
                                            </compoundCondition>
                                            <assessmentStatement comparator="eq">
                                                    <attributeStatement role="__15" eventType="attribution" />
                                                    <attributeStatement role="__16" eventType="attribution" />
                                            </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onEnd" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__5" eventType="attribution" />
                                                <attributeStatement role="__6" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="start" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="a">
                                <compoundCondition operator="or">
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onPause" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onAbort" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__11" eventType="attribution" />
                                                <attributeStatement role="__12" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="abort" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onEnd" component="m" />
                        <bind role="onResume" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__13" interface="__2" />
                        <bind role="__14" interface="__2" />
                        <bind role="__15" interface="__2" />
                        <bind role="__16" interface="__2" />
                </link>

                <context id='online'>
                    <property name='prop'/>
                    <link xconnector="a">
                        <bind role="onPause" component="m" />
                        <bind role="onAbort" component="m" />
                        <bind role="abort" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__7" interface="prop" />
                        <bind role="__8" interface="prop" />
                        <bind role="__9" interface="prop" />
                        <bind role="__10" interface="prop" />
                        <bind role="__11" interface="prop" />
                        <bind role="__12" interface="prop" />
                    </link>
                </context>

                <property name="__2" />
        </body>
</ncl>]])

local str = dietncl.parsestring( [[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="_______11">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="_______21">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onPause" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__11" eventType="attribution" />
                                                        <attributeStatement role="__12" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="abort" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="_______31">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onAbort" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__11" eventType="attribution" />
                                                        <attributeStatement role="__12" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="abort" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="_______41">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__15" eventType="attribution" />
                                                        <attributeStatement role="__16" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="_______51">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onResume" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__15" eventType="attribution" />
                                                        <attributeStatement role="__16" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__13" eventType="attribution" />
                                                        <attributeStatement role="__14" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <context id="online">
                        <property name="prop" />
                        <link xconnector="_______21">
                                <bind role="onPause" component="m" />
                                <bind role="abort" component="m" />
                                <bind role="pause" component="m" />
                                <bind role="__7" interface="prop" />
                                <bind role="__8" interface="prop" />
                                <bind role="__11" interface="prop" />
                                <bind role="__12" interface="prop" />
                        </link>
                        <link xconnector="_______31">
                                <bind role="onAbort" component="m" />
                                <bind role="abort" component="m" />
                                <bind role="pause" component="m" />
                                <bind role="__9" interface="prop" />
                                <bind role="__10" interface="prop" />
                                <bind role="__11" interface="prop" />
                                <bind role="__12" interface="prop" />
                        </link>
                </context>
                <property name="__2" />
                <link xconnector="_______11">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                </link>
                <link xconnector="_______41">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__15" interface="__2" />
                        <bind role="__16" interface="__2" />
                </link>
                <link xconnector="_______51">
                        <bind role="onResume" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__13" interface="__2" />
                        <bind role="__14" interface="__2" />
                        <bind role="__15" interface="__2" />
                        <bind role="__16" interface="__2" />
                </link>
        </body>
</ncl>]])

assert (filter.apply (ncl))
assert (ncl:equal (str))

local ncl = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onBegin" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onEnd" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__5" eventType="attribution" />
                                                <attributeStatement role="__6" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="start" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="__7" eventType="attribution" />
                                    <attributeStatement role="__8" eventType="attribution" />
                                </assessmentStatement>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
                <property name="__2" />
        </body>
</ncl>]])

local str = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="__01">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__11">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <property name="__2" />
                <link xconnector="__01">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
                <link xconnector="__11">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
        </body>
</ncl>

<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="__01">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__11">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <property name="__2" />
                <link xconnector="__01">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
                <link xconnector="__11">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
        </body>
</ncl>]])

assert (filter.apply (ncl))
assert (ncl:equal (str))

local ncl = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onBegin" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                    <compoundCondition operator="and">
                                                        <simpleCondition role="onResume" />
                                                        <assessmentStatement comparator="eq">
                                                            <attributeStatement role="__3" eventType="attribution" />
                                                            <attributeStatement role="__4" eventType="attribution" />
                                                        </assessmentStatement>
                                                    </compoundCondition>
                                                    <compoundCondition operator="and">
                                                        <simpleCondition role="onEnd" />
                                                        <assessmentStatement comparator="eq">
                                                            <attributeStatement role="__12" eventType="attribution" />
                                                            <attributeStatement role="__11" eventType="attribution" />
                                                        </assessmentStatement>
                                                    </compoundCondition>
                                                    <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                    </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__5" eventType="attribution" />
                                                <attributeStatement role="__6" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                    <simpleAction role="start" delay="15s" />
                                    <simpleAction role="pause" />
                                </compoundAction>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="__7" eventType="attribution" />
                                    <attributeStatement role="__8" eventType="attribution" />
                                </assessmentStatement>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onEnd" component="m" />
                        <bind role="onResume" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                        <bind role="__9" interface="__2" />
                        <bind role="__10" interface="__2" />
                        <bind role="__11" interface="__2" />
                        <bind role="__12" interface="__2" />
                </link>
                <property name="__2" />
        </body>
</ncl>]])

local str = dietncl.parsestring ([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="__01">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__21">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onResume" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                        <attributeStatement role="__4" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                        <simpleAction role="set" value="1" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="__31">
                                <compoundCondition operator="and">
                                        <simpleCondition role="onEnd" />
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__5" eventType="attribution" />
                                                        <attributeStatement role="__6" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__9" eventType="attribution" />
                                                        <attributeStatement role="__10" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__12" eventType="attribution" />
                                                        <attributeStatement role="__11" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__7" eventType="attribution" />
                                                        <attributeStatement role="__8" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                        <simpleAction role="set" value="1" />
                                </compoundAction>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <property name="__2" />
                <link xconnector="__01">
                        <bind role="onBegin" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                </link>
                <link xconnector="__21">
                        <bind role="onResume" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                        <bind role="__9" interface="__2" />
                        <bind role="__10" interface="__2" />
                        <bind role="set" interface="__42" />
                </link>
                <link xconnector="__31">
                        <bind role="onEnd" component="m" />
                        <bind role="start" component="m" />
                        <bind role="pause" component="m" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                        <bind role="__7" interface="__2" />
                        <bind role="__8" interface="__2" />
                        <bind role="__9" interface="__2" />
                        <bind role="__10" interface="__2" />
                        <bind role="__11" interface="__2" />
                        <bind role="__12" interface="__2" />
                        <bind role="set" interface="__52" />
                </link>
                <property name="__42" value="0" />
                <property name="__52" value="0" />
        </body>
</ncl>]])

assert (filter.apply(ncl))
assert (ncl:equal (str))
