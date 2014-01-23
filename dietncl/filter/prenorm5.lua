--[[ prenorm5.lua -- Fifth pre-normalization step.
     Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia

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

-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM5, implements the fifth pre-normalization
-- step: It guarantees that the compound actions and compound statements of
-- all connectors are binary and its compound conditions are either binary
-- or ternary, and have exactly one child (assessment or compound)
-- statement.
--
-- Depends: PRENORM1.

local filter = {}

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- Updates the binds of links after insertion of the respective
-- simpleCondition has been inserted into a new compoundCondition.
--
local function update_binds (attrR1, attrR2, conn, ncl, cond)
   local binds={}
   local property
   local parent

   for link in ncl:gmatch('link') do
      if link.xconnector==conn.id then
         for bind in link:gmatch('bind') do
            if bind.role==cond.role then
               property=xml.new('property')
               property.name=aux.gen_id(ncl)
               parent=link:parent()
               parent:insert(property)
               binds[1]=xml.new('bind')
               binds[1].role=attrR1
               binds[1].component=(link:parent()).id
               binds[1].interface=property.name
               binds[2]=binds[1]:clone()
               binds[2].role=attrR2
               link:insert(binds[1])
               link:insert(binds[2])
            end
         end
      end
   end
end


---
-- Turns unary elements (i.e. simpleCondition) into binary ones by adding
-- the unary into a new compound element together with a new tautological
-- assessment statement.
--
local function turn_unary_binary(conn, ncl, ...)
   local compound
   local stat
   local attr={}
   local deter

   for condition in conn:gmatch(...) do
      compound=xml.new('compoundCondition')
      compound.operator='and'
      stat=xml.new('assessmentStatement')
      stat.operator='eq'
      attr[1]=xml.new('attributeStatement')
      attr[1].role=aux.gen_id(ncl)
      attr[1].eventType='attribution'
      attr[2]=xml.new('attributeStatement')
      attr[2].role=aux.gen_id(ncl)
      attr[2].eventType='attribution'
      (condition:parent()):insert(compound)
      condition=xml.remove(condition:parent(), condition)
      compound:insert(stat)
      stat:insert(attr[1])
      stat:insert(attr[2])
      compound:insert(condition)
      update_binds(attr[1].role, attr[2].role, conn, ncl, condition)
   end
end

---
-- Turns binary elements into ternary ones inserting them into a new
-- compound element.
--
local function turn_binary_ternary(conn, ncl)
   local counter=2
   local test=0
   local root
   local remain
   local stat
   local attr={}

   for comp in conn:gmatch('compoundCondition') do
      if counter==2 then
         if root then
            conn:insert(root)
         end
         counter=0
         root=xml.new('compoundCondition')
         root.operator='and'
         remain=nil
      end
      remain=xml.remove(conn, comp)
      root:insert(remain)
      counter=counter+1
      test=test+1
   end

   --print(counter)

   if counter==1 and test>2 then
      root=xml.new('compoundCondition')
      root.operator='and'
      conn:insert(root)
      remain=xml.remove(remain:parent(), remain)
      root:insert(remain)
      stat=xml.new('assessmentStatement')
      stat.operator='eq'
      attr[1]=xml.new('attributeStatement')
      attr[1].role=aux.gen_id(ncl)
      attr[1].eventType='attribution'
      attr[2]=xml.new('attributeStatement')
      attr[2].role=aux.gen_id(ncl)
      attr[2].eventType='attribution'
      root:insert(stat)
      stat:insert(attr[1])
      stat:insert(attr[2])
   end


end

function filter.apply (ncl)
   for conn in ncl:gmatch('causalConnector') do
      turn_unary_binary(conn, ncl, 'simpleCondition')
      turn_binary_ternary(conn, ncl)
   end
end

return filter
