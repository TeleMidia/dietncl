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
local attr={}

local print = print
local ipairs = ipairs


local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- Adds binary elements to binary chain of these same elements .
--

local function make_binary_tree (parent, ncl)
   local attr={}
   local child={}
   local root={['compoundCondition_operator'] = 'and', ['compoundAction_operator'] = 'par', ['compoundStatement_operator'] = 'and',
				[1] = 'compoundCondition',              [2] = 'compoundAction',              [3] = 'compoundStatement'}

   local stat

   if parent == nil or #parent == 0 then
		return
   elseif #parent == 1 then
		-- Remove the parent
		child[1] = xml.remove(parent, parent[1])
		(parent:parent()):insert(child[1])
		xml.remove(parent)

		make_binary_chain (child[1])

   elseif #parent == 2 then

		for index, element in ipairs(parent) do
		 -- In case of one compound element and one assessment statements.
		 if element:tag() == 'assessmentStatement' or element:tag() == 'compoundStatement' then
		   child[index] = xml.remove(parent, element)
		   element:insert(child[index])
		   goto finish
		 end

		 child[index] = element

		 -- In case of one simple element and one assessment statement.
		 if child[index]:tag() == 'simpleAction' or child[index]:tag() == 'simpleCondition' then
		   goto finish
         end

		 -- In case of two compound elements.
		 if index == 2 then
		   stat=xml.new('assessmentStatement')
	       stat.operator='eq'
	       attr[1]=xml.new('attributeStatement')
	       attr[1].role=aux.gen_id(ncl)
	       attr[1].eventType='attribution'
	       attr[2]=xml.new('attributeStatement')
	       attr[2].role=aux.gen_id(ncl)
		   attr[2].eventType='attribution'
		   stat:insert(attr[1])
	       stat:insert(attr[2])
	       parent:insert(stat)
		 end

		end

		::finish::

		make_binary_tree (parent[1])
		make_binary_tree (parent[2])

   else

		root[parent:tag()] = xml.new(parent:tag())
		root[parent:tag()].operator = parent.operator or (root[parent:tag()] .. '_operator')
		parent:insert(root[parent:tag()])

		for index, element in ipairs(parent) do
          -- Gather compound elements into a compound element.
		  if index > 1  and element:tag() == root[parent:tag()] then
		    child[index] = xml.remove(parent, element)
			root[parent:tag()]:insert(child[index])
		  else
			-- Gather assessment statements into a compound statement.
			if root['compoundStatement'] == nil then
			  root['compoundStatement'] = xml.new('compoundStatement')
			  root['compoundStatement'].operator = 'and'
			  parent:insert(root['compoundStatement'])
			else
			  child[index] = xml.remove(parent, element)
			  root['compoundStatement']:insert(child[index])
			end

		  end

		end

		if #parent == 2 then
		  make_binary_tree (parent[1])
		  make_binary_tree (parent[2])
		end

   end

end

---
-- Applies filter for restriction (5)
--

function filter.apply (ncl)
   local compound
   local counter = 2
   local new_bind
   local property
   local parent
   local role_table={}
   local stat

   for conn in ncl:gmatch('causalConnector') do

     -- Turns unary elements (i.e. simpleCondition) into binary ones by adding
     -- the unary into a new compound element together with a new tautological
     -- assessment statement.

	 for tag_cond in conn:gmatch('simpleCondition') do
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
		(tag_cond:parent()):insert(compound)
		tag_cond=xml.remove(tag_cond:parent(), tag_cond)
		compound:insert(stat)
		stat:insert(attr[1])
		stat:insert(attr[2])
		compound:insert(tag_cond)
	 end

	-- Breakage procedure: creates a chain of binary compound conditions.
	for compound in conn:gmatch('^compound[AC].*$', nil, nil, 4) do
		make_binary_tree (compound, ncl)
	end

	-- Updates all binds of the respective links after breakage procedure.
	for parent_tag in conn:gmatch('^compound[ACS].*$', nil, nil, 4) do
	  for link in ncl:gmatch('link') do
	    if link.xconnector==conn.id then
	      for tag in parent_tag:gmatch('^simple[ACS].*$', nil, nil, 4) do
	        for bind in link:gmatch('bind') do

			  if bind.role==tag.role then
			     for attr in (tag:parent():parent()):gmatch('attributeStatement') do

				   -- Avoids duplicates of binds referring to the same attributeStatement.
				   if role_table[attr.role] == nil then
				     role_table[attr.role] = 'exists'
				   else
				     goto continue
				   end

				   if counter == 2 then
				     property=xml.new('property')
				     property.name=aux.gen_id(ncl)
				     parent=(link:parent()):insert(property)
				     counter=0
				   end

				   new_bind=xml.new('bind')

				   if (link:parent()).id then
			             new_bind.component=(link:parent()).id
				   end

				   new_bind.role=attr.role
				   new_bind.interface=property.name
				   counter=counter+1
				   link:insert(new_bind)

				   ::continue::

				 end
			  end
		    end
		  end
	    end
	  end
    end

    end

    --print(ncl)
    return ncl

end

return filter
