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
			</causalConnector>
		</connectorBase>
	</head>
	<body>
		<media id='m'/>
		<link xconnector='c'>
			<bind role='onBegin' component='m'/>
			<bind role='onEnd' component='m'/>
		</link>
	</body>
</ncl>]])

local str = dietncl.parsestring([[
<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__0" eventType="attribution" />
                                                        <attributeStatement role="__1" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onBegin" />
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="__2" eventType="attribution" />
                                                        <attributeStatement role="__3" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onEnd" />
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="__4" eventType="attribution" />
                                                <attributeStatement role="__5" eventType="attribution" />
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
                        <bind role="__0" interface="__6" />
                        <bind role="__1" interface="__6" />
                        <bind role="__2" interface="__7" />
                        <bind role="__3" interface="__7" />
                        <bind role="__4" interface="__8" />
                        <bind role="__5" interface="__8" />
                </link>
                <property name="__6" />
                <property name="__7" />
                <property name="__8" />
        </body>
</ncl>]])

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
						<attributeStatement role='R1'/>
						<attributeStatement role='R2'/>
					</assessmentStatement>
				</compoundCondition >
				<compoundAction operator='and'>
					<simpleAction role='start' delay='15s'/>
					<assessmentStatement comparator='eq'>
						<attributeStatement role='R3' eventType='attribution'/>
						<attributeStatement role='R4' eventType='attribution'/>
					</assessmentStatement>
				</compoundAction>
			</causalConnector>
		</connectorBase>
	</head>

	<body>
		<media id='m'/>

		<context id='bubble'>
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
]]

local ncl = dietncl.parsestring (str)
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
			</causalConnector>
		</connectorBase>
	</head>

	<body>
		<media id='m'/>
		<media id='n'/>
		<media id='o'/>
		<media id='p'/>
		<media id='s'/>

		<context id='bubble'>
			<media id='w'/>
			<port id='first' component='w'/>

			<link xconnector='c'>
			     <bind role='onBegin' component='m'/>
			     <bind role='onEnd' component='o'/>
			     <bind role='start' component='w'/>
			     <bind role='pause' component='m'/>
			 </link>
		</context>

		<link xconnector='a'>
			<bind role='onBegin' component='o'/>
			<bind role='onSelection' component='n'/>
		</link>
	</body>
</ncl>]])


local str =  [[

<ncl>
        <head>
                <connectorBase>
                        <causalConnector id="c">
                                <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="_______0" eventType="attribution" />
                                                        <attributeStatement role="_______1" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onBegin" delay="5s" />
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="_______2" eventType="attribution" />
                                                        <attributeStatement role="_______3" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onEnd" />
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="_______4" eventType="attribution" />
                                                <attributeStatement role="_______5" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                                <compoundAction operator="and">
                                        <simpleAction role="start" delay="15s" />
                                        <simpleAction role="pause" />
                                </compoundAction>
                        </causalConnector>
                        <causalConnector id="a">
                                <compoundCondition operator="and">
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="_______9" eventType="attribution" />
                                                        <attributeStatement role="_______10" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onBegin" delay="15s" />
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="_______11" eventType="attribution" />
                                                        <attributeStatement role="_______12" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onSelection" />
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="_______13" eventType="attribution" />
                                                <attributeStatement role="_______14" eventType="attribution" />
                                        </assessmentStatement>
                                </compoundCondition>
                        </causalConnector>
                </connectorBase>
        </head>
        <body>
                <media id="m" />
                <media id="n" />
                <media id="o" />
                <media id="p" />
                <media id="s" />
                <context id="bubble">
                        <media id="w" />
                        <port id="first" component="w" />
                        <link xconnector="c">
                                <bind role="onBegin" component="m" />
                                <bind role="onEnd" component="o" />
                                <bind role="start" component="w" />
                                <bind role="pause" component="m" />
                                <bind component="bubble" role="_______0" interface="_______6" />
                                <bind component="bubble" role="_______1" interface="_______6" />
                                <bind component="bubble" role="_______2" interface="_______7" />
                                <bind component="bubble" role="_______3" interface="_______7" />
                                <bind component="bubble" role="_______4" interface="_______8" />
                                <bind component="bubble" role="_______5" interface="_______8" />
                        </link>
                        <property name="_______6" />
                        <property name="_______7" />
                        <property name="_______8" />
                </context>
                <link xconnector="a">
                        <bind role="onBegin" component="o" />
                        <bind role="onSelection" component="n" />
                        <bind role="_______9" interface="_______15" />
                        <bind role="_______10" interface="_______15" />
                        <bind role="_______11" interface="_______16" />
                        <bind role="_______12" interface="_______16" />
                        <bind role="_______13" interface="_______17" />
                        <bind role="_______14" interface="_______17" />
                </link>
                <property name="_______15" />
                <property name="_______16" />
                <property name="_______17" />
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
							<assessmentStatement operator='eq'>
								<attributeStatement role='i' eventType='attribution'/>
								<attributeStatement role='j' eventType='attribution'/>
							</assessmentStatement>
						</compoundCondition>
						<compoundCondition operator='and'>
							<simpleCondition role='onResume'/>
							<assessmentStatement operator='eq'>
								<attributeStatement role='k' eventType='attribution'/>
								<attributeStatement role='l' eventType='attribution'/>
							</assessmentStatement>
						</compoundCondition>
						<assessmentStatement operator='eq'>
							<attributeStatement role='a' eventType='attribution'/>
							<attributeStatement role='b' eventType='attribution'/>
						</assessmentStatement>
					</compoundCondition>
					<compoundCondition operator='and'>
						<compoundCondition operator='and'>
				             		<simpleCondition role='onEnd'/>
					            	<assessmentStatement operator='eq'>
					                   		<attributeStatement role='e' eventType='attribution'/>
				                     			<attributeStatement role='f' eventType='attribution'/>
					             	</assessmentStatement>
				              	</compoundCondition>
				               	<compoundCondition operator='and'>
									<simpleCondition role='onAbort'/>
									<assessmentStatement operator='eq'>
										<attributeStatement role='g' eventType='attribution'/>
										<attributeStatement role='h' eventType='attribution'/>
									</assessmentStatement>
							</compoundCondition>
							<assessmentStatement operator='eq'>
								<attributeStatement role='c' eventType='attribution'/>
								<attributeStatement role='d' eventType='attribution'/>
							</assessmentStatement>
						</compoundCondition>
						<assessmentStatement operator='eq'>
							<attributeStatement role='r' eventType='attribution'/>
							<attributeStatement role='s' eventType='attribution'/>
						</assessmentStatement>
				</compoundCondition>
			</causalConnector>
		</connectorBase>
	</head>

	<body>
		<media id='m'/>
		<link xconnector='c'>
			<bind role='onBegin' component='value'/>
			<bind role='onResume' component='value'/>
			<bind role='a' component='value'/>
			<bind role='b' component='value'/>
			<bind role='i' component='value'/>
			<bind role='j' component='value'/>
			<bind role='k' component='value'/>
			<bind role='l' component='value'/>
			<bind role='onEnd' component='m'/>
			<bind role='onAbort' component='m'/>
			<bind role='c' component='value'/>
			<bind role='d' component='value'/>
			<bind role='e' component='value'/>
			<bind role='f' component='value'/>
			<bind role='g' component='value'/>
			<bind role='h' component='value'/>
			<bind role='r' component='value'/>
			<bind role='s' component='value'/>
		</link>
	</body>
</ncl>]]


local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))
assert (ncl:equal (dietncl.parsestring (str)))

-- Apply filter on a more robust NCL document.

local ncl = dietncl.parsestring ([[
<ncl>
	<head>
		<connectorBase>
			<causalConnector id='c'>
				<compoundCondition operator='or'>
					<compoundCondition operator='and'>
						<simpleCondition role='onBegin' delay='5s'/>
						<simpleCondition role='onSelection' key='ENTER'/>
						<simpleCondition role='onEnd'/>
						<simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
					</compoundCondition>
					<compoundCondition operator='and'>
						<simpleCondition role='onResume'/>
						<simpleCondition role='onPause'/>
						<compoundStatement operator='and'>
							<assessmentStatement comparator='ne'>
								<attributeStatement role='R17' eventType='attribution'/>
								<attributeStatement role='R18' eventType='attribution'/>
							</assessmentStatement>
							<assessmentStatement comparator='ne'>
								<attributeStatement role='R19' eventType='attribution'/>
								<attributeStatement role='R20' eventType='attribution'/>
							</assessmentStatement>
						</compoundStatement>
					</compoundCondition>
					<compoundCondition operator='and'>
						<simpleCondition role='beginning' transition='presentation' eventType='presentation'/>
						<assessmentStatement comparator='ne'>
							<attributeStatement role='R1' eventType='attribution'/>
							<attributeStatement role='R2' eventType='attribution'/>
						</assessmentStatement/>
					</compoundCondition>
				</compoundCondition >
				<compoundAction operator='par'>
					<compoundAction operator='seq'>
						<simpleAction role='start'/>
						<simpleAction role='pause'/>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='R3' eventType='attribution'/>
							<attributeStatement role='R4' eventType='attribution'/>
						</assessmentStatement>
					</compoundAction>
					<compoundAction operator='par'>
						<simpleAction role='abort'/>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='R9' eventType='attribution'/>
							<attributeStatement role='R10' eventType='attribution'/>
						</assessmentStatement>
					</compoundAction>
					<compoundAction operator='seq'>
						<simpleAction role='resume'/>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='R11' eventType='attribution'/>
							<attributeStatement role='R12' eventType='attribution'/>
						</assessmentStatement>
					</compoundAction>
				</compoundAction>
				<compoundStatement operator='and'>
					<assessmentStatement comparator='eq'>
							<attributeStatement role='R13' eventType='attribution'/>
							<attributeStatement role='R14' eventType='attribution'/>
					</assessmentStatement>
					<assessmentStatement comparator='eq'>
							<attributeStatement role='R15' eventType='attribution'/>
							<attributeStatement role='R16' eventType='attribution'/>
					</assessmentStatement>
				</compoundStatement>
			</causalConnector>

			<causalConnector id='a'>
				<compoundCondition operator='or'>
					<compoundCondition operator='and'>
						<simpleCondition role='onBegin' delay='15s'/>
						<simpleCondition role='onSelection'/>
						<simpleCondition role='onBeginSelect' key='ENTER' transition='starts' eventType='selection'/>
						<simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
						<simpleCondition role='start_again' eventType='presentation' transition='presentation'/>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='R5' eventType='attribution'/>
							<attributeStatement role='R6' eventType='attribution'/>
						</assessmentStatement/>
					</compoundCondition>
					<compoundCondition operator='and'>
						<simpleCondition role='onResume'/>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='R7' eventType='attribution'/>
							<attributeStatement role='R8' eventType='attribution'/>
						</assessmentStatement/>
					</compoundCondition>
				</compoundCondition>
				<simpleAction role='start'/>
				<assessmentStatement comparator='ne'>
						<attributeStatement role='R21' eventType='attribution'/>
						<attributeStatement role='R22' eventType='attribution'/>
				</assessmentStatement>
			</causalConnector>
		</connectorBase>
	</head>

	<body>
		<property name='master_value'/>

		<media id='m'/>
		<media id='n'/>
		<media id='o'/>
		<media id='p'/>
		<media id='s'/>

		<context id='bubble_one'>
			<property name='value'/>
			<property name='another_value'/>
			<media id='w'/>
			<port id='first' component='w'/>

			<link xconnector='c'>
				<bind role='onBegin' component='m'/>
				<bind role='onSelection' component='n'>
					<bindParam name='key' value='ENTER'/>
				</bind>
				<bind role='onEnd' component='o'/>
				<bind role='onResume' component='w'/>
				<bind role='onPause' component='n'/>
				<bind role='beginning' component='m'/>
				<bind role='start' comnponent='n'/>
				<bind role='pause' component='m'/>
				<bind role='abort' component='w'/>
				<bind role='resume' component='n'/>
				<bind role='R1' component='value'/>
				<bind role='R2' component='another_value'/>
				<bind role='R3' component='value'/>
				<bind role='R4' component='value'/>
				<bind role='R9' component='value'/>
				<bind role='R10' component='value'/>
				<bind role='R11' component='value'/>
				<bind role='R12' component='value'/>
				<bind role='R13' component='value'/>
				<bind role='R14' component='value'/>
				<bind role='R17' component='value'/>
				<bind role='R18' component='value'/>
				<bind role='R19' component='value'/>
				<bind role='R20' component='value'/>
			</link>
		</context>

		<link xconnector='a'>
			<bind role='onBegin' component='o'/>
			<bind role='onSelection' component='n'/>
			<bind role='onResume' component='m'/>
			<bind role='onBeginSelect' component='p'>
				<bindParam name='key' value='ENTER'>
			</bind>
			<bind role='onResume' component='s'/>
			<bind role='start' component='n'/>
			<bind role='R5' component='master_value'/>
			<bind role='R6' component='master_value'/>
			<bind role='R7' component='master_value'/>
			<bind role='R8' component='master_value'/>
			<bind role='R21' component='master_value'/>
			<bind role='R22' component='master_value'/>
			<bind role='onAbort' component='m'/>
			<bind role='start_again' component='s'/>
			<bind role='start' component='m'>
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
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________8" eventType="attribution" />
                                                        <attributeStatement role="___________9" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onResume" />
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________10" eventType="attribution" />
                                                        <attributeStatement role="___________11" eventType="attribution" />
                                                </assessmentStatement>
                                                <simpleCondition role="onPause" />
                                        </compoundCondition>
                                </compoundCondition>
                                <compoundCondition operator="or">
                                        <compoundCondition operator="and">
                                                <compoundCondition operator="and">
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________6" eventType="attribution" />
                                                                <attributeStatement role="___________7" eventType="attribution" />
                                                        </assessmentStatement>
                                                        <simpleCondition transition="aborts" eventType="presentation" role="onAbort" />
                                                </compoundCondition>
                                                <compoundCondition operator="and">
                                                        <compoundCondition operator="and">
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________2" eventType="attribution" />
                                                                        <attributeStatement role="___________3" eventType="attribution" />
                                                                </assessmentStatement>
                                                                <simpleCondition role="onSelection" key="ENTER" />
                                                        </compoundCondition>
                                                        <compoundCondition operator="and">
                                                                <compoundCondition operator="and">
                                                                        <assessmentStatement comparator="eq">
                                                                                <attributeStatement role="___________0" eventType="attribution" />
                                                                                <attributeStatement role="___________1" eventType="attribution" />
                                                                        </assessmentStatement>
                                                                        <simpleCondition role="onBegin" delay="5s" />
                                                                </compoundCondition>
                                                                <compoundCondition operator="and">
                                                                        <assessmentStatement comparator="eq">
                                                                                <attributeStatement role="___________4" eventType="attribution" />
                                                                                <attributeStatement role="___________5" eventType="attribution" />
                                                                        </assessmentStatement>
                                                                        <simpleCondition role="onEnd" />
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
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________34" eventType="attribution" />
                                                                <attributeStatement role="___________35" eventType="attribution" />
                                                        </assessmentStatement>
                                                        <simpleCondition role="onSelection" />
                                                </compoundCondition>
                                                <compoundCondition operator="and">
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________38" eventType="attribution" />
                                                                <attributeStatement role="___________39" eventType="attribution" />
                                                        </assessmentStatement>
                                                        <simpleCondition transition="aborts" eventType="presentation" role="onAbort" />
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________46" eventType="attribution" />
                                                        <attributeStatement role="___________47" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <compoundCondition operator="and">
                                                <compoundCondition operator="and">
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________36" eventType="attribution" />
                                                                <attributeStatement role="___________37" eventType="attribution" />
                                                        </assessmentStatement>
                                                        <simpleCondition transition="starts" key="ENTER" eventType="selection" role="onBeginSelect" />
                                                </compoundCondition>
                                                <compoundCondition operator="and">
                                                        <compoundCondition operator="and">
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________32" eventType="attribution" />
                                                                        <attributeStatement role="___________33" eventType="attribution" />
                                                                </assessmentStatement>
                                                                <simpleCondition role="onBegin" delay="15s" />
                                                        </compoundCondition>
                                                        <compoundCondition operator="and">
                                                                <assessmentStatement comparator="eq">
                                                                        <attributeStatement role="___________40" eventType="attribution" />
                                                                        <attributeStatement role="___________41" eventType="attribution" />
                                                                </assessmentStatement>
                                                                <simpleCondition transition="presentation" eventType="presentation" role="start_again" />
                                                        </compoundCondition>
                                                        <assessmentStatement comparator="eq">
                                                                <attributeStatement role="___________50" eventType="attribution" />
                                                                <attributeStatement role="___________51" eventType="attribution" />
                                                        </assessmentStatement>
                                                </compoundCondition>
                                                <assessmentStatement comparator="eq">
                                                        <attributeStatement role="___________48" eventType="attribution" />
                                                        <attributeStatement role="___________49" eventType="attribution" />
                                                </assessmentStatement>
                                        </compoundCondition>
                                        <assessmentStatement comparator="eq">
                                                <attributeStatement role="___________44" eventType="attribution" />
                                                <attributeStatement role="___________45" eventType="attribution" />
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
                                        <attributeStatement role="___________42" eventType="attribution" />
                                        <attributeStatement role="___________43" eventType="attribution" />
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
                        <bind component="bubble_one" role="___________2" interface="___________26" />
                        <bind component="bubble_one" role="___________3" interface="___________26" />
                        <bind component="bubble_one" role="___________0" interface="___________27" />
                        <bind component="bubble_one" role="___________1" interface="___________27" />
                        <bind component="bubble_one" role="___________4" interface="___________28" />
                        <bind component="bubble_one" role="___________5" interface="___________28" />
                        <bind component="bubble_one" role="___________20" interface="___________29" />
                        <bind component="bubble_one" role="___________21" interface="___________29" />
                        <bind component="bubble_one" role="___________18" interface="___________30" />
                        <bind component="bubble_one" role="___________19" interface="___________30" />
                        <bind component="bubble_one" role="___________6" interface="___________31" />
                        <bind component="bubble_one" role="___________7" interface="___________31" />
                </link>
                <property name="___________26" />
                <property name="___________27" />
                <property name="___________28" />
                <property name="___________29" />
                <property name="___________30" />
                <property name="___________31" />
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
                <bind role="___________34" interface="___________52" />
                <bind role="___________35" interface="___________52" />
                <bind role="___________38" interface="___________53" />
                <bind role="___________39" interface="___________53" />
                <bind role="___________46" interface="___________54" />
                <bind role="___________47" interface="___________54" />
                <bind role="___________36" interface="___________55" />
                <bind role="___________37" interface="___________55" />
                <bind role="___________32" interface="___________56" />
                <bind role="___________33" interface="___________56" />
                <bind role="___________40" interface="___________57" />
                <bind role="___________41" interface="___________57" />
                <bind role="___________50" interface="___________58" />
                <bind role="___________51" interface="___________58" />
                <bind role="___________48" interface="___________59" />
                <bind role="___________49" interface="___________59" />
        </link>
        <property name="___________52" />
        <property name="___________53" />
        <property name="___________54" />
        <property name="___________55" />
        <property name="___________56" />
        <property name="___________57" />
        <property name="___________58" />
        <property name="___________59" />
	</body>
</ncl>]]

assert(filter.apply(ncl))
assert(ncl:equal (dietncl.parsestring(str)))
