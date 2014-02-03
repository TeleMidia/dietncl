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

-- First case: only two compound elements, each containing two simple child elements.

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
			<causalConnector id='c'>
				<compoundCondition operator='and'>
					<compoundCondition operator='and'>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='_______0' eventType='attribution'/>
							<attributeStatement role='_______1' eventType='attribution'/>
						</assessmentStatement>
						<simpleCondition role='onBegin' delay='5s'/>
					</compoundCondition>
					<compoundCondition operator='and'>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='_______2' eventType='attribution'/>
							<attributeStatement role='_______3' eventType='attribution'/>
						</assessmentStatement>
						<simpleCondition role='onEnd'/>
					</compoundCondition>
					<assessmentStatement comparator='eq'>
						<attributeStatement role='_______4' eventType='attribution'/>
						<attributeStatement role='_______5' eventType='attribution'/>
					</assessmentStatement>
				</compoundCondition >
				<compoundAction operator='and'>
						<simpleAction role='start' delay='15s'/>
						<simpleAction role='pause'/>
				</compoundAction>
			</causalConnector>
			<causalConnector id='a'>
				<compoundCondition operator='or'>
					<compoundCondition operator='and'>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='_______9' eventType='attribution'/>
							<attributeStatement role='_______10' eventType='attribution'/>
						</assessmentStatement>
						<simpleCondition role='onBegin' delay='15s'/>
					</compoundCondition>
					<compoundCondition operator='and'>
						<assessmentStatement comparator='eq'>
							<attributeStatement role='_______11' eventType='attribution'/>
							<attributeStatement role='_______12' eventType='attribution'/>
						</assessmentStatement>
						<simpleCondition role='onSelection'/>
					</compoundCondition>
					<assessmentStatement comparator='eq'>
						<attributeStatement role='_______13' eventType='attribution'/>
						<attributeStatement role='_______14' eventType='attribution'/>
					</assessmentStatement>
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
			     <bind component='bubble' role='_______0' interface='_______6'/>
			     <bind component='bubble' role='_______1' interface='_______6'/>
			     <bind component='bubble' role='_______2' interface='_______7'/>
			     <bind component='bubble' role='_______3' interface='_______7'/>
			     <bind component='bubble' role='_______4' interface='_______8'/>
			     <bind component='bubble' role='_______5' interface='_______8'/>
			 </link>
			 <property name='______6'/>
			 <property name='______7'/>
			 <property name='______8'/>
		</context>
		<link xconnector='a'>
			<bind role='onBegin' component='o'/>
			<bind role='onSelection' component='n'/>
			<bind role='_______9' interface='_______15'/>
			<bind role='_______10' interface='_______15'/>
			<bind role='_______11' interface='_______16'/>
			<bind role='_______12' interface='_______16'/>
			<bind role='_______13' interface='_______17'/>
			<bind role='_______14' interface='_______17'/>
		</link>
		<property name='______15'/>
		<property name='______16'/>
		<property name='______17'/>
	</body>
</ncl>]]

assert(filter.apply(ncl))
assert(ncl:equal (dietncl.parsestring(str)))

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

--[==[local ncl = dietncl.parsestring (str)
assert (filter.apply (ncl))
--assert (ncl:equal (dietncl.parsestring (str)))

local ncl = dietncl.parsestring ([[
<ncl>
	<head>
		<connectorBase>

			<causalConnector id='c'>
				<compoundCondition operator='and'>
					<compoundCondition operator='and'>
						<simpleCondition role='onBegin' delay='5s'/>
						<simpleCondition role='onSelection'/>
						<simpleCondition role='onEnd'/>
						<simpleCondition role='onBeginSelect' key='PLAY' transition='starts' eventType='selection'/>
						<simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
					<compoundCondition operator='and'>
						<simpleCondition role='onResume'/>
					</compoundCondition>
				</compoundCondition>
					<compoundCondition operator='and'>
						<simpleCondition role='beginning' transition='presentation' eventType='presentation'/>
						<simpleCondition role='start_again' eventType='presentation' transition='presentation'/>
						<simpleCondition role='select' transition='starts' eventType='selection' key='ENTER'/>
						<assessmentStatement comparator='ne'>
							<attributeStatement role='R1' eventType='attribution'/>
							<attributeStatement role='R2' eventType='attribution'/>
						</assessmentStatement/>
					</compoundCondition>
				</compoundCondition >
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
			</causalConnector>
		</connectorBase>
	</head>

	<body>
		<property name='value_1'/>

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
				<bind role='onSelection' component='n'/>
				<bind role='onEnd' component='o'/>
				<bind role='onResume'>
				<bind role='onBeginSelect' component='p'>
					<bindParam name='key' value='ENTER'/>
				</bind>
				<bind role='R1' component='value'/>
				<bind role='R2' component='another_value'/>
			</link>
		</context>

		<link xconnector='a'>
			<bind role='onBegin' component='o'/>
			<bind role='onSelection' component='n'/>
			<bind role='onBeginSelect' component='p'>
				<bindParam name='key' value='ENTER'>
			</bind>
			<bind role='onResume'/>
			<bind role='R5' component='value_1'/>
			<bind role='R6' component='value_1'/>
			<bind role='R7' component='value_1'/>
			<bind role='R8' component='value_1'/>
			<bind role='R9' component='value_1'/>
			<bind role='R10' component='value_1'/>
			<bind role='onAbort' component='m'/>
			<bind role='start_again' component='s'/>
		</link>
	</body>
</ncl>]])

assert(filter.apply(ncl))

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
						<assessmentStatement operator="eq">
							<attributeStatement role="_ _0" eventType="attribution" />
							<attributeStatement role="_ _1" eventType="attribution" />
						</assessmentStatement>
						<simpleCondition role="onBegin" />
					</compoundCondition>
					<compoundCondition operator="and">
						<assessmentStatement operator="eq">
							<attributeStatement role="_ _2" eventType="attribution" />
							<attributeStatement role="_ _3" eventType="attribution" />
						</assessmentStatement>
						<simpleCondition role="onEnd" />
					</compoundCondition>
					<assessmentStatement operator="eq">
						<attributeStatement role="_ _4" eventType="attribution" />
						<attributeStatement role="_ _5" eventType="attribution" />
					</assessmentStatement>
				</compoundCondition>
			</causalConnector>
		</connectorBase>
	</head>
	<body>
		<media id="m"/>
		<link xconnector="c">
			<bind role="onBegin" component="m" />
			<bind role='onEnd' component="m" />
			<bind role='_ _0' component="_ _6" />
			<bind role='_ _1' component="_ _6" />
			<bind role='_ _2' component="_ _7" />
			<bind role='_ _3' component="_ _7" />
			<bind role="_ _4" component="_ _8" />
			<bind role="_ _5" component="_ _8" />
		</link>
		<property name="_ _6" />
		<property name="_ _7" />
	</body>
</ncl>]])

assert (filter.apply (ncl))
--assert (ncl:equal (str))
]==]--
