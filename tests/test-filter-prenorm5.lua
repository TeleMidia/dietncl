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
         <assessmentStatement comparator='eq'>
	 <attributeStatement role='R9' eventType='attribution'/>
	 <attributeStatement role='R10' eventType='attribution'/>
         </assessmentStatement/>
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

--[=[local ncl = dietncl.parsestring ([[
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
    <property name='value_1'/>

     <media id='m'/>
     <media id='n'/>
     <media id='o'/>
     <media id='p'/>
     <media id='s'/>

     <context id='bubble_one'>
        <media id='w'/>
        <port id='first' component='w'/>

        <link xconnector='c'>
             <bind role='onBegin' component='m'/>
         </link>
     </context>

    <link xconnector='a'>
            <bind role='onBegin' component='o'/>
             <bind role='onSelection' component='n'/>
      </link>


 </body>
</ncl>]])

assert(filter.apply(ncl))]=]--



