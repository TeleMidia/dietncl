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
local type = type

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- Inserts singular compound element TAG into a new compound element of
-- type TAG addind a vacuous, tautological statement.
--

--[[local function correct_singularity (ncl, conn, root, test, counter, tag)
   local stat

   elseif counter[tag]==1 then
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
      root[tag]:insert(stat)
      conn:insert(root[tag])
   end

end
]]--

local function make_binary_tree (father, ncl)
   local parent
   local tag
   local root={['compoundCondition_operator'] = 'and', ['compoundAction_operator'] = 'par', ['compoundStatement_operator'] = 'and',
				[1] = 'compoundCondition',              [2] = 'compoundAction',              [3] = 'compoundStatement'}

   local remain={}
   local stat
   local attr={}
   local counter={}

   for comp in father:gmatch('^compound[AC].*$', nil, nil, 4) do
    if comp:parent()==father then
	make_binary_tree (comp, ncl)
	-- print(('-'):rep(80))
	-- print(comp)
	--print(counter[comp:tag()])
	-- print(comp:tag())
	-- print(('-'):rep(80))
	 if counter[comp:tag()]==nil then counter[comp:tag()]=0 end
	
	 if counter[comp:tag()]==2 then
	    root[comp:tag()]=xml.new(comp:tag())
	    root[comp:tag()].operator=root[comp:tag() .. '_operator']

	    for i=1, 2 do
		remain[i]=xml.remove(father, remain[i])
		root[comp:tag()]:insert(remain[i])
	    end
	    
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
	    root[comp:tag()]:insert(stat)
	    
	    father:insert(root[comp:tag()])
	    print(root[comp:tag()])
	    counter[comp:tag()]=0
	 end

	 remain[counter[comp:tag()]+1]=comp
	 counter[comp:tag()]=counter[comp:tag()]+1
       end
    
   end
   
   for index, element in ipairs(remain) do
     for reference, counter in ipairs(counter) do
     
     if counter==0 then
         element=xml.remove(father, element)
         (father:parent()):insert(element)
         xml.remove(father, father:parent())
     elseif counter==1 then
	-- Creates a new assessmentStatement
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

	-- Inserts a new compound element that enbodies the two remaining compounds
	element=xml.remove(element:parent(), element)
	remain[2]=xml.remove(remain[2]:parent(), remain[2])
	root[reference]=xml.new(comp:tag())
	root[reference].operator=root[comp:tag() .. '_operator']
	root[reference]:insert(remain[1])
	root[reference]:insert(remain[2])
	root[reference]:insert(stat)
	parent:insert(root[reference])
     end
     
     end
   end

end

---
-- Adds binary elements to binary chain of these same elements .
--

--[[local function make_binary_chain (ncl, conn)
   local counter={['compoundCondition']=2, ['compoundAction']=2, ['compoundStatement']=2}
   local test={['compoundCondition']=0, ['compoundAction']=0, ['compoundStatement']=0}

   local root={}
   local remain

   for comp in conn:gmatch('^compound[ACS].*$', nil, nil, 4) do
	 if counter[comp:tag()]==2 then
	   if root[comp:tag()] then      -- Ignores the first compound condition
		conn:insert(root[comp:tag()]) -- Insertion of compound conditions (roots)
	   end

	   root[comp:tag()]=xml.new(comp:tag())

	   if comp:tag() == 'compoundCondition' then
		root[comp:tag()]=xml.new('compoundCondition')
		root[comp:tag()].operator='and'
		remain=nil
	   elseif comp:tag() == 'compoundAction' then
		root[comp:tag()]=xml.new('compoundAction')
		root[comp:tag()].operator='par'
		remain=nil
	   elseif comp:tag() == 'compoundStatement' then
		root[comp:tag()]=xml.new('compoundStatement')
		root[comp:tag()].operator='and'
		remain=nil
	   end

		counter[comp:tag()]=0
	 end

	remain=xml.remove(comp:parent(), comp)
	root[comp:tag()]:insert(remain)
	counter[comp:tag()]=counter[comp:tag()]+1
	test[comp:tag()]=test[comp:tag()]+1

	end
   end

   ---
   -- In case only one compound element is left (singularity case)
   -- The breakage procedure is valid only for n-ary compound elements
   -- as long as n>2.
   --

   --Check for compound elements (action, condition or statement) singularity
   correct_singularity(ncl, conn, root, test, counter, 'compoundAction')
   correct_singularity(ncl, conn, root, test, counter, 'compoundCondition')
   correct_singularity(ncl, conn, root, test, counter, 'compoundStatement')

end]]--

---
-- Applies filter for restriction (5)
--

function filter.apply (ncl)
   local compound
   local counter=2
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
           if tag_cond:parent()==conn then
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
	 end

	-- Breakage procedure: creates a chain of binary compound conditions.
	-- make_binary_chain (ncl, conn)
	make_binary_tree(conn, ncl)

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

    print(ncl)
    return ncl

end

return filter
