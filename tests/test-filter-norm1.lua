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

assert (filter.apply (ncl))
--assert (ncl:equal (str))
