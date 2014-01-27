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
    <simpleCondition role='onBegin' delay='5s'/>
     <simpleCondition role='onSelection'/>
     <simpleCondition role='onEnd'/>
     <simpleCondition role='onBeginSelect' key='PLAY' transition='starts' eventType='selection'/>
     <simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
     <compoundCondition operator='and'>
         <simpleCondition role='start_again' eventType='presentation' transition='presentation'/>
         <compoundStatement operator='and'>
	 <assessmentStatement comparator='ne' >
	          <attributeStatement  role='R3' eventType='attribution'/>
	          <attributeStatement  role='R4' eventType='attribution'/>
	 </assessmentStatement>
	 <assessmentStatement comparator='e' >
	          <attributeStatement  role='R5' eventType='attribution'/>
	          <attributeStatement  role='R6' eventType='attribution'/>
	 </assessmentStatement>
         </compoundStatement>
     </compoundCondition >
     <compoundStatement operator='and'>
	 <assessmentStatement comparator='ne' >
	          <attributeStatement  role='R7' eventType='attribution'/>
	          <attributeStatement  role='R8' eventType='attribution'/>
	 </assessmentStatement>
	 <assessmentStatement comparator='e' >
	          <attributeStatement  role='R9' eventType='attribution'/>
	          <attributeStatement  role='R10' eventType='attribution'/>
	 </assessmentStatement>
         </compoundStatement>
         <compoundStatement operator='and'>
	 <assessmentStatement comparator='ne' >
	          <attributeStatement  role='R11' eventType='attribution'/>
	          <attributeStatement  role='R12' eventType='attribution'/>
	 </assessmentStatement>
	 <assessmentStatement comparator='e' >
	          <attributeStatement  role='R13' eventType='attribution'/>
	          <attributeStatement  role='R14' eventType='attribution'/>
	 </assessmentStatement>
         </compoundStatement>
        <compoundAction operator='par'>
	     <simpleAction role='abort'/>
	     <simpleAction role='stop'/>
        </compoundAction>
	 
	 <compoundAction operator='seq'>
	      <simpleAction role='pause'/>
	      <assessmentStatement comparator='eq' >
	          <attributeStatement  role='R1' eventType='attribution'/>
	          <attributeStatement  role='R2' eventType='attribution'/>
                  </assessmentStatement>		  
	 </compoundAction>
	 <compoundAction operator='par'>
	         <simpleAction role='start'/>
	 </compoundAction>
    <simpleAction role='_start' transition='starts' eventType='presentation' delay='10s'/>
   </causalConnector>
   
   <causalConnector id='a'>
    <simpleCondition role='onBegin' delay='15s'/>
     <simpleCondition role='onSelection'/>
     <simpleCondition role='onBeginSelect' key='ENTER' transition='starts' eventType='selection'/>
     <simpleCondition role='onAbort' transition='aborts' eventType='presentation'/>
	 
	 <compoundAction operator='par'>
	     <simpleAction role='abort'/>
	     <simpleAction role='stop'/>
	 </compoundAction>
	 
	 <compoundAction operator='seq'>
	      <simpleAction role='pause'/>
	      <assessmentStatement comparator='eq' >
	          <attributeStatement  role='R1' eventType='attribution'/>
	          <attributeStatement  role='R2' eventType='attribution'/> 
	     </assessmentStatement>
	 </compoundAction>
	 <compoundAction operator='par'>
	         <simpleAction role='start'/>
	 </compoundAction>
    <simpleAction role='_start' transition='starts' eventType='presentation' delay='10s'/>
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
	 <bind role='onBeginSelect' component='p'>
	     <bindParam name='key' value='ENTER'/>
	 </bind>
	 <bind role='R1' component='value'/>
	 <bind role='R2' component='value'/>
	 <bind role='abort' component='s'/>
	 <bind role='stop' component='o'/>
	 <bind role='_start' component='s'/>
	 <bind role='start' component='w'/>
	 <bind role='R3' component='value'/>
	 <bind role='R4' component='another_value'/>
	 <bind role='R5' component='another_value'/>
	 <bind role='R6' component='another_value'/>
	 <bind role='R7' component='value'/>
	 <bind role='R8' component='another_value'/>
	 <bind role='R9' component='value'/>
	 <bind role='R10' component='value'/>
	 <bind role='R11' component='value'/>
	 <bind role='R12' component='another_value'/>
	 <bind role='R13' component='value'/>
	 <bind role='R14' component='value'/>
	 
       </link>
   </context>
   
    <link xconnector='a'>
            <bind role='onBegin' component='o'/>
             <bind role='onSelection' component='n'/>
  	 <bind role='onBeginSelect' component='p'>
  	   <bindParam name='key' value='ENTER'>
  	 </bind>
  	 <bind role='R1' component='value_1'/>
  	 <bind role='R2' component='value_1'/>
  	 <bind role='onAbort' component='m'/>
  	 <bind role='start' component='s'/>
      </link>
   
   
 </body>
</ncl>]])

assert(filter.apply(ncl))


