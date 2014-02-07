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
local filter = require ('dietncl.filter.norm1')

_ENV = nil

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
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onEnd" component="m" />
                        <bind role="__0" interface="__2" />
                        <bind role="__1" interface="__2" />
                        <bind role="__3" interface="__2" />
                        <bind role="__4" interface="__2" />
                        <bind role="__5" interface="__2" />
                        <bind role="__6" interface="__2" />
                </link>
                <property name="__2" />
        </body>
</ncl>]])

local str = ncl
assert (filter.apply (ncl))
assert (ncl:equal (str))

local ncl = dietncl.parsestring([[
<ncl>
    <head>
        <connectorBase>
                <causalConnector id="c">
                        <compoundCondition operator="or">
                                <compoundCondition operator="or">
                                        <compoundStatement operator="and">
                                                <assessmentStatement comparator="ne">
                                                        <attributeStatement role="R17" eventType="attribution" />
                                                        <attributeStatement role="R18" eventType="attribution" />
                                                </assessmentStatement>
                                                <assessmentStatement comparator="ne">
                                                        <attributeStatement role="R19" eventType="attribution" />
                                                        <attributeStatement role="R20" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundStatement>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onResume" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________8" eventType="attribution" />
                                                        <attributeStatement role="___________9" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition role="onPause" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________10" eventType="attribution" />
                                                        <attributeStatement role="___________11" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                </compoundCondition>
                                <compoundCondition operator="or">
                                        <compoundCondition operator="or">
                                                <compoundCondition operator="and">
                                                        <simpleCondition transition="aborts" eventType="presentation" role="onAbort" />
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________6" eventType="attribution" />
                                                                <attributeStatement role="___________7" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <compoundCondition operator="or">
                                                        <compoundCondition operator="and">
                                                                <simpleCondition role="onSelection" key="ENTER" />
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________2" eventType="attribution" />
                                                                        <attributeStatement role="___________3" eventType="attribution" />
                                                                </assessmentStatement>
                                                        </compoundCondition>
                                                        <compoundCondition operator="or">
                                                                <compoundCondition operator="and">
                                                                        <simpleCondition role="onBegin" delay="5s" />
                                                                        <assessmentStatement comparator="eq">
                                                                                <attributeStatement role="___________0" eventType="attribution" />
                                                                                <attributeStatement role="___________1" eventType="attribution" />
                                                                        </assessmentStatement>
                                                                </compoundCondition>
                                                                <compoundCondition operator="and">
                                                                        <simpleCondition role="onEnd" />
                                                                        <assessmentStatement comparator="eq">
                                                                                <attributeStatement role="___________4" eventType="attribution" />
                                                                                <attributeStatement role="___________5" eventType="attribution" />
                                                                        </assessmentStatement>
                                                                </compoundCondition>
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________20" eventType="attribution" />
                                                                        <attributeStatement role="___________21" eventType="attribution" />
                                                                </assessmentStatement>
                                                        </compoundCondition>
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________18" eventType="attribution" />
                                                                <attributeStatement role="___________19" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________16" eventType="attribution" />
                                                        <attributeStatement role="___________17" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <simpleCondition transition="presentation" eventType="presentation" role="beginning" />
                                                <assessmentStatement comparator="ne">
                                                        <attributeStatement role="R1" eventType="attribution" />
                                                        <attributeStatement role="R2" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="___________14" eventType="attribution" />
                                                <attributeStatement role="___________15" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________12" eventType="attribution" />
                                        <attributeStatement role="___________13" eventType="attribution" />
                                </assessmentStatement>
                        </compoundCondition>
                        <compoundAction operator="par">
                                <compoundAction operator="par">
                                        <simpleAction role="abort" />
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="R9" eventType="attribution" />
                                                <attributeStatement role="R10" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundAction>
                                <compoundAction operator="par">
                                        <compoundAction operator="seq">
                                                <simpleAction role="start" />
                                                <simpleAction role="pause" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="R3" eventType="attribution" />
                                                        <attributeStatement role="R4" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundAction>
                                        <compoundAction operator="seq">
                                                <simpleAction role="resume" />
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="R11" eventType="attribution" />
                                                        <attributeStatement role="R12" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundAction>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="___________24" eventType="attribution" />
                                                <attributeStatement role="___________25" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundAction>
                                <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________22" eventType="attribution" />
                                        <attributeStatement role="___________23" eventType="attribution" />
                                </assessmentStatement>
                        </compoundAction>
                        <compoundStatement operator="and">
                                <assessmentStatement comparator="eq">
                                        <attributeStatement role="R13" eventType="attribution" />
                                        <attributeStatement role="R14" eventType="attribution" />
                                </assessmentStatement>
                                <assessmentStatement comparator="eq">
                                        <attributeStatement role="R15" eventType="attribution" />
                                        <attributeStatement role="R16" eventType="attribution" />
                                </assessmentStatement>
                        </compoundStatement>
                </causalConnector>
                <causalConnector id="a">
                        <compoundCondition operator="or">
                                <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                                <compoundCondition operator="and">
                                                        <simpleCondition role="onSelection" />
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________28" eventType="attribution" />
                                                                <attributeStatement role="___________29" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <compoundCondition operator="and">
                                                        <simpleCondition transition="aborts" eventType="presentation" role="onAbort" />
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________32" eventType="attribution" />
                                                                <attributeStatement role="___________33" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________40" eventType="attribution" />
                                                        <attributeStatement role="___________41" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <compoundCondition operator="and">
                                                        <simpleCondition transition="starts" key="ENTER" eventType="selection" role="onBeginSelect" />
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________30" eventType="attribution" />
                                                                <attributeStatement role="___________31" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <compoundCondition operator="and">
                                                        <compoundCondition operator="and">
                                                                <simpleCondition role="onBegin" delay="15s" />
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________26" eventType="attribution" />
                                                                        <attributeStatement role="___________27" eventType="attribution" />
                                                                </assessmentStatement>
                                                        </compoundCondition>
                                                        <compoundCondition operator="and">
                                                                <simpleCondition transition="presentation" eventType="presentation" role="start_again" />
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________34" eventType="attribution" />
                                                                        <attributeStatement role="___________35" eventType="attribution" />
                                                                </assessmentStatement>
                                                        </compoundCondition>
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________44" eventType="attribution" />
                                                                <attributeStatement role="___________45" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________42" eventType="attribution" />
                                                        <attributeStatement role="___________43" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="___________38" eventType="attribution" />
                                                <attributeStatement role="___________39" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundCondition operator="and">
                                        <simpleCondition role="onResume" />
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="R7" eventType="attribution" />
                                                <attributeStatement role="R8" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________36" eventType="attribution" />
                                        <attributeStatement role="___________37" eventType="attribution" />
                                </assessmentStatement>
                        </compoundCondition>
                        <simpleAction role="start" />
                        <assessmentStatement comparator="ne">
                                <attributeStatement role="R21" eventType="attribution" />
                                <attributeStatement role="R22" eventType="attribution" />
                        </assessmentStatement>
                </causalConnector>
        </connectorBase>
    </head>
    <body>
        <property name="master_value" />
        <media id="m" />
        <media id="n" />
        <media id="o" />
        <media id="p" />
        <media id="s" />
        <context id="bubble_one">
                <property name="value" />
                <property name="another_value" />
                <media id="w" />
                <port id="first" component="w" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind component="n" role="onSelection">
                                <bindParam name="key" value="ENTER" />
                        </bind>
                        <bind role="onEnd" component="o" />
                        <bind role="onResume" component="w" />
                        <bind role="onPause" component="n" />
                        <bind role="beginning" component="m" />
                        <bind role="start" comnponent="n" />
                        <bind role="pause" component="m" />
                        <bind role="abort" component="w" />
                        <bind role="resume" component="n" />
                        <bind role="R1" component="value" />
                        <bind role="R2" component="another_value" />
                        <bind role="R3" component="value" />
                        <bind role="R4" component="value" />
                        <bind role="R9" component="value" />
                        <bind role="R10" component="value" />
                        <bind role="R11" component="value" />
                        <bind role="R12" component="value" />
                        <bind role="R13" component="value" />
                        <bind role="R14" component="value" />
                        <bind role="R17" component="value" />
                        <bind role="R18" component="value" />
                        <bind role="R19" component="value" />
                        <bind role="R20" component="value" />
                        <bind component="bubble_one" role="___________0" interface="value" />
                        <bind component="bubble_one" role="___________1" interface="value" />
                        <bind component="bubble_one" role="___________2" interface="value" />
                        <bind component="bubble_one" role="___________3" interface="value" />
                        <bind component="bubble_one" role="___________4" interface="value" />
                        <bind component="bubble_one" role="___________5" interface="value" />
                        <bind component="bubble_one" role="___________6" interface="value" />
                        <bind component="bubble_one" role="___________7" interface="value" />
                        <bind component="bubble_one" role="___________8" interface="value" />
                        <bind component="bubble_one" role="___________9" interface="value" />
                        <bind component="bubble_one" role="___________10" interface="value" />
                        <bind component="bubble_one" role="___________11" interface="value" />
                        <bind component="bubble_one" role="___________12" interface="value" />
                        <bind component="bubble_one" role="___________13" interface="value" />
                        <bind component="bubble_one" role="___________14" interface="value" />
                        <bind component="bubble_one" role="___________15" interface="value" />
                        <bind component="bubble_one" role="___________16" interface="value" />
                        <bind component="bubble_one" role="___________17" interface="value" />
                        <bind component="bubble_one" role="___________18" interface="value" />
                        <bind component="bubble_one" role="___________19" interface="value" />
                        <bind component="bubble_one" role="___________20" interface="value" />
                        <bind component="bubble_one" role="___________21" interface="value" />
                        <bind component="bubble_one" role="___________22" interface="value" />
                        <bind component="bubble_one" role="___________23" interface="value" />
                        <bind component="bubble_one" role="___________24" interface="value" />
                        <bind component="bubble_one" role="___________25" interface="value" />
                </link>
        </context>
        <link xconnector="a">
                <bind role="onBegin" component="o" />
                <bind role="onSelection" component="n" />
                <bind role="onResume" component="m" />
                <bind role="onBeginSelect" component="p">
                        <bindParam name="key" value="ENTER" />
                        <bind role="onResume" component="s" />
                        <bind role="start" component="n" />
                        <bind role="R5" component="master_value" />
                        <bind role="R6" component="master_value" />
                        <bind role="R7" component="master_value" />
                        <bind role="R8" component="master_value" />
                        <bind role="R21" component="master_value" />
                        <bind role="R22" component="master_value" />
                        <bind role="onAbort" component="m" />
                        <bind role="start_again" component="s" />
                        <bind role="start" component="m" />
                </bind>
                <bind role="___________26" interface="master_value" />
                <bind role="___________27" interface="master_value" />
                <bind role="___________28" interface="master_value" />
                <bind role="___________29" interface="master_value" />
                <bind role="___________30" interface="master_value" />
                <bind role="___________31" interface="master_value" />
                <bind role="___________32" interface="master_value" />
                <bind role="___________33" interface="master_value" />
                <bind role="___________34" interface="master_value" />
                <bind role="___________35" interface="master_value" />
                <bind role="___________36" interface="master_value" />
                <bind role="___________37" interface="master_value" />
                <bind role="___________38" interface="master_value" />
                <bind role="___________39" interface="master_value" />
                <bind role="___________40" interface="master_value" />
                <bind role="___________41" interface="master_value" />
                <bind role="___________42" interface="master_value" />
                <bind role="___________43" interface="master_value" />
                <bind role="___________44" interface="master_value" />
                <bind role="___________45" interface="master_value" />
        </link>
    </body>
</ncl>]])

local str = [[
<ncl>
    <head>
        <connectorBase>
            <causalConnector id="c">
                <compoundCondition operator="or">
                    <compoundCondition operator="and">
                        <compoundCondition operator="or">
                            <compoundCondition operator="and">
                                <compoundCondition operator="or">
                                    <simpleCondition role="onResume" />
                                    <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________8" eventType="attribution" />
                                        <attributeStatement role="___________9" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <compoundStatement operator="and">
                                    <assessmentStatement comparator="ne">
                                        <attributeStatement role="R17" eventType="attribution" />
                                        <attributeStatement role="R18" eventType="attribution" />
                                    </assessmentStatement>
                                    <assessmentStatement comparator="ne">
                                        <attributeStatement role="R19" eventType="attribution" />
                                        <attributeStatement role="R20" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundStatement>
                            </compoundCondition>
                            <compoundCondition operator="and">
                                <compoundCondition operator="and">
                                    <simpleCondition role="onPause" />
                                    <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________10" eventType="attribution" />
                                        <attributeStatement role="___________11" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <compoundStatement operator="and">
                                    <assessmentStatement comparator="ne">
                                        <attributeStatement role="R17" eventType="attribution" />
                                        <attributeStatement role="R18" eventType="attribution" />
                                    </assessmentStatement>
                                    <assessmentStatement comparator="ne">
                                        <attributeStatement role="R19" eventType="attribution" />
                                        <attributeStatement role="R20" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundStatement>
                            </compoundCondition>
                        </compoundCondition>
                        <assessmentStatement comparator="eq">
                            <attributeStatement role="___________12" eventType="attribution" />
                            <attributeStatement role="___________13" eventType="attribution" />
                        </assessmentStatement>
                    </compoundCondition>
                    <compoundCondition operator="and">
                        <compoundCondition operator="or">
                            <compoundCondition operator="and">
                                <compoundCondition operator="or">
                                    <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                            <simpleCondition role="onAbort" eventType="presentation" transition="aborts" />
                                            <assessmentStatement comparator="eq">
                                                <attributeStatement role="___________6" eventType="attribution" />
                                                <attributeStatement role="___________7" eventType="attribution" />
                                            </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                            <attributeStatement role="___________16" eventType="attribution" />
                                            <attributeStatement role="___________17" eventType="attribution" />
                                        </assessmentStatement>
                                    </compoundCondition>
                                    <compoundCondition operator="and">
                                        <compoundCondition operator="or">
                                            <compoundCondition operator="and">
                                                <compoundCondition operator="and">
                                                    <simpleCondition role="onSelection" key="ENTER" />
                                                    <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________2" eventType="attribution" />
                                                        <attributeStatement role="___________3" eventType="attribution" />
                                                    </assessmentStatement>
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                    <attributeStatement role="___________18" eventType="attribution" />
                                                    <attributeStatement role="___________19" eventType="attribution" />
                                                </assessmentStatement>
                                            </compoundCondition>
                                            <compoundCondition operator="and">
                                                <compoundCondition operator="or">
                                                    <compoundCondition operator="and">
                                                        <compoundCondition operator="and">
                                                        <simpleCondition role="onBegin" delay="5s" />
                                                        <assessmentStatement comparator="eq">
                                                            <attributeStatement role="___________0" eventType="attribution" />
                                                            <attributeStatement role="___________1" eventType="attribution" />
                                                        </assessmentStatement>
                                                        </compoundCondition>
                                                        <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________20" eventType="attribution" />
                                                        <attributeStatement role="___________21" eventType="attribution" />
                                                        </assessmentStatement>
                                                    </compoundCondition>
                                                    <compoundCondition operator="and">
                                                        <compoundCondition operator="and">
                                                        <simpleCondition role="onEnd" />
                                                        <assessmentStatement comparator="eq">
                                                            <attributeStatement role="___________4" eventType="attribution" />
                                                            <attributeStatement role="___________5" eventType="attribution" />
                                                        </assessmentStatement>
                                                        </compoundCondition>
                                                        <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________20" eventType="attribution" />
                                                        <attributeStatement role="___________21" eventType="attribution" />
                                                        </assessmentStatement>
                                                    </compoundCondition>
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                    <attributeStatement role="___________18" eventType="attribution" />
                                                    <attributeStatement role="___________19" eventType="attribution" />
                                                </assessmentStatement>
                                            </compoundCondition>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                            <attributeStatement role="___________16" eventType="attribution" />
                                            <attributeStatement role="___________17" eventType="attribution" />
                                        </assessmentStatement>
                                    </compoundCondition>
                                </compoundCondition>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="___________14" eventType="attribution" />
                                    <attributeStatement role="___________15" eventType="attribution" />
                                </assessmentStatement>
                            </compoundCondition>
                            <compoundCondition operator="and">
                                <compoundCondition operator="and">
                                    <simpleCondition role="beginning" eventType="presentation" transition="presentation" />
                                    <assessmentStatement comparator="ne">
                                        <attributeStatement role="R1" eventType="attribution" />
                                        <attributeStatement role="R2" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="___________14" eventType="attribution" />
                                    <attributeStatement role="___________15" eventType="attribution" />
                                </assessmentStatement>
                            </compoundCondition>
                        </compoundCondition>
                        <assessmentStatement comparator="eq">
                            <attributeStatement role="___________12" eventType="attribution" />
                            <attributeStatement role="___________13" eventType="attribution" />
                        </assessmentStatement>
                    </compoundCondition>
                </compoundCondition>
                <compoundAction operator="par">
                    <compoundAction operator="par">
                        <simpleAction role="abort" />
                        <assessmentStatement comparator="eq">
                            <attributeStatement role="R9" eventType="attribution" />
                            <attributeStatement role="R10" eventType="attribution" />
                        </assessmentStatement>
                    </compoundAction>
                    <compoundAction operator="par">
                        <compoundAction operator="seq">
                            <simpleAction role="start" />
                            <simpleAction role="pause" />
                            <assessmentStatement comparator="eq">
                                <attributeStatement role="R3" eventType="attribution" />
                                <attributeStatement role="R4" eventType="attribution" />
                            </assessmentStatement>
                        </compoundAction>
                        <compoundAction operator="seq">
                            <simpleAction role="resume" />
                            <assessmentStatement comparator="eq">
                                <attributeStatement role="R11" eventType="attribution" />
                                <attributeStatement role="R12" eventType="attribution" />
                            </assessmentStatement>
                        </compoundAction>
                        <assessmentStatement comparator="eq">
                            <attributeStatement role="___________24" eventType="attribution" />
                            <attributeStatement role="___________25" eventType="attribution" />
                        </assessmentStatement>
                    </compoundAction>
                    <assessmentStatement comparator="eq">
                        <attributeStatement role="___________22" eventType="attribution" />
                        <attributeStatement role="___________23" eventType="attribution" />
                    </assessmentStatement>
                </compoundAction>
                <compoundStatement operator="and">
                    <assessmentStatement comparator="eq">
                        <attributeStatement role="R13" eventType="attribution" />
                        <attributeStatement role="R14" eventType="attribution" />
                    </assessmentStatement>
                    <assessmentStatement comparator="eq">
                        <attributeStatement role="R15" eventType="attribution" />
                        <attributeStatement role="R16" eventType="attribution" />
                    </assessmentStatement>
                </compoundStatement>
            </causalConnector>
            <causalConnector id="a">
                <compoundCondition operator="or">
                    <compoundCondition operator="and">
                        <compoundCondition operator="and">
                            <compoundCondition operator="and">
                                <compoundCondition operator="and">
                                    <simpleCondition role="onSelection" />
                                    <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________28" eventType="attribution" />
                                        <attributeStatement role="___________29" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <compoundCondition operator="and">
                                    <simpleCondition role="onAbort" eventType="presentation" transition="aborts" />
                                    <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________32" eventType="attribution" />
                                        <attributeStatement role="___________33" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="___________40" eventType="attribution" />
                                    <attributeStatement role="___________41" eventType="attribution" />
                                </assessmentStatement>
                            </compoundCondition>
                            <compoundCondition operator="and">
                                <compoundCondition operator="and">
                                    <simpleCondition transition="starts" key="ENTER" eventType="selection" role="onBeginSelect" />
                                    <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________30" eventType="attribution" />
                                        <attributeStatement role="___________31" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <compoundCondition operator="and">
                                    <compoundCondition operator="and">
                                        <simpleCondition role="onBegin" delay="15s" />
                                        <assessmentStatement comparator="eq">
                                            <attributeStatement role="___________26" eventType="attribution" />
                                            <attributeStatement role="___________27" eventType="attribution" />
                                        </assessmentStatement>
                                    </compoundCondition>
                                    <compoundCondition operator="and">
                                        <simpleCondition role="start_again" eventType="presentation" transition="presentation" />
                                        <assessmentStatement comparator="eq">
                                            <attributeStatement role="___________34" eventType="attribution" />
                                            <attributeStatement role="___________35" eventType="attribution" />
                                        </assessmentStatement>
                                    </compoundCondition>
                                    <assessmentStatement comparator="eq">
                                        <attributeStatement role="___________44" eventType="attribution" />
                                        <attributeStatement role="___________45" eventType="attribution" />
                                    </assessmentStatement>
                                </compoundCondition>
                                <assessmentStatement comparator="eq">
                                    <attributeStatement role="___________42" eventType="attribution" />
                                    <attributeStatement role="___________43" eventType="attribution" />
                                </assessmentStatement>
                            </compoundCondition>
                            <assessmentStatement comparator="eq">
                                <attributeStatement role="___________38" eventType="attribution" />
                                <attributeStatement role="___________39" eventType="attribution" />
                            </assessmentStatement>
                        </compoundCondition>
                        <assessmentStatement comparator="eq">
                            <attributeStatement role="___________36" eventType="attribution" />
                            <attributeStatement role="___________37" eventType="attribution" />
                        </assessmentStatement>
                    </compoundCondition>
                    <compoundCondition operator="and">
                        <compoundCondition operator="and">
                            <simpleCondition role="onResume" />
                            <assessmentStatement comparator="eq">
                                <attributeStatement role="R7" eventType="attribution" />
                                <attributeStatement role="R8" eventType="attribution" />
                            </assessmentStatement>
                        </compoundCondition>
                        <assessmentStatement comparator="eq">
                            <attributeStatement role="___________36" eventType="attribution" />
                            <attributeStatement role="___________37" eventType="attribution" />
                        </assessmentStatement>
                    </compoundCondition>
                </compoundCondition>
                <simpleAction role="start" />
                <assessmentStatement comparator="ne">
                    <attributeStatement role="R21" eventType="attribution" />
                    <attributeStatement role="R22" eventType="attribution" />
                </assessmentStatement>
            </causalConnector>
        </connectorBase>
    </head>
    <body>
        <property name="master_value" />
        <media id="m" />
        <media id="n" />
        <media id="o" />
        <media id="p" />
        <media id="s" />
        <context id="bubble_one">
                <property name="value" />
                <property name="another_value" />
                <media id="w" />
                <port id="first" component="w" />
                <link xconnector="c">
                        <bind role="onBegin" component="m" />
                        <bind role="onSelection" component="n">
                                <bindParam name="key" value="ENTER" />
                        </bind>
                        <bind role="onEnd" component="o" />
                        <bind role="onResume" component="w" />
                        <bind role="onPause" component="n" />
                        <bind role="beginning" component="m" />
                        <bind role="start" comnponent="n" />
                        <bind role="pause" component="m" />
                        <bind role="abort" component="w" />
                        <bind role="resume" component="n" />
                        <bind role="R1" component="value" />
                        <bind role="R2" component="another_value" />
                        <bind role="R3" component="value" />
                        <bind role="R4" component="value" />
                        <bind role="R9" component="value" />
                        <bind role="R10" component="value" />
                        <bind role="R11" component="value" />
                        <bind role="R12" component="value" />
                        <bind role="R13" component="value" />
                        <bind role="R14" component="value" />
                        <bind role="R17" component="value" />
                        <bind role="R18" component="value" />
                        <bind role="R19" component="value" />
                        <bind role="R20" component="value" />
                        <bind component="bubble_one" role="___________0" interface="value" />
                        <bind component="bubble_one" role="___________1" interface="value" />
                        <bind component="bubble_one" role="___________2" interface="value" />
                        <bind component="bubble_one" role="___________3" interface="value" />
                        <bind component="bubble_one" role="___________4" interface="value" />
                        <bind component="bubble_one" role="___________5" interface="value" />
                        <bind component="bubble_one" role="___________6" interface="value" />
                        <bind component="bubble_one" role="___________7" interface="value" />
                        <bind component="bubble_one" role="___________8" interface="value" />
                        <bind component="bubble_one" role="___________9" interface="value" />
                        <bind component="bubble_one" role="___________10" interface="value" />
                        <bind component="bubble_one" role="___________11" interface="value" />
                        <bind component="bubble_one" role="___________12" interface="value" />
                        <bind component="bubble_one" role="___________13" interface="value" />
                        <bind component="bubble_one" role="___________14" interface="value" />
                        <bind component="bubble_one" role="___________15" interface="value" />
                        <bind component="bubble_one" role="___________16" interface="value" />
                        <bind component="bubble_one" role="___________17" interface="value" />
                        <bind component="bubble_one" role="___________18" interface="value" />
                        <bind component="bubble_one" role="___________19" interface="value" />
                        <bind component="bubble_one" role="___________20" interface="value" />
                        <bind component="bubble_one" role="___________21" interface="value" />
                        <bind component="bubble_one" role="___________22" interface="value" />
                        <bind component="bubble_one" role="___________23" interface="value" />
                        <bind component="bubble_one" role="___________24" interface="value" />
                        <bind component="bubble_one" role="___________25" interface="value" />
                </link>
        </context>
        <link xconnector="a">
                <bind role="onBegin" component="o" />
                <bind role="onSelection" component="n" />
                <bind role="onResume" component="m" />
                <bind role="onBeginSelect" component="p">
                        <bindParam name="key" value="ENTER" />
                        <bind role="onResume" component="s" />
                        <bind role="start" component="n" />
                        <bind role="R5" component="master_value" />
                        <bind role="R6" component="master_value" />
                        <bind role="R7" component="master_value" />
                        <bind role="R8" component="master_value" />
                        <bind role="R21" component="master_value" />
                        <bind role="R22" component="master_value" />
                        <bind role="onAbort" component="m" />
                        <bind role="start_again" component="s" />
                        <bind role="start" component="m" />
                </bind>
                <bind role="___________26" interface="master_value" />
                <bind role="___________27" interface="master_value" />
                <bind role="___________28" interface="master_value" />
                <bind role="___________29" interface="master_value" />
                <bind role="___________30" interface="master_value" />
                <bind role="___________31" interface="master_value" />
                <bind role="___________32" interface="master_value" />
                <bind role="___________33" interface="master_value" />
                <bind role="___________34" interface="master_value" />
                <bind role="___________35" interface="master_value" />
                <bind role="___________36" interface="master_value" />
                <bind role="___________37" interface="master_value" />
                <bind role="___________38" interface="master_value" />
                <bind role="___________39" interface="master_value" />
                <bind role="___________40" interface="master_value" />
                <bind role="___________41" interface="master_value" />
                <bind role="___________42" interface="master_value" />
                <bind role="___________43" interface="master_value" />
                <bind role="___________44" interface="master_value" />
                <bind role="___________45" interface="master_value" />
        </link>
</body>
</ncl>]]

local ncl = dietncl.parsestring (str)
assert(filter.apply (ncl))
assert(ncl:equal (dietncl.parsestring (str)))
