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
   local child
   local exclude = {'compoundStatement', 'assessmentStatement', 'simpleCondition', 'simpleAction', 'attributeStatement'}
   local root={['compoundCondition_operator'] = 'and', ['compoundAction_operator'] = 'par', ['compoundStatement_operator'] = 'and',
			 [1] = 'compoundCondition',                    [2] = 'compoundAction',                   [3] = 'compoundStatement',
			 ['compoundCondition'] = 'simpleCondition',                                                         ['compoundAction'] = 'simpleAction'}

   local stat

	-- Returns function in case parent's length is zero (there are no child elements).
	if #parent == 0 then
		return
	end

	-- In case parent has exactly one child, parent's child must be removed from parent and then inserted into parent's parent.
	if #parent == 1 then
		child = xml.remove (parent, 1)		-- Remove child from parent and insert it into parent's parent
		parent:parent():insert(child)
		xml.remove(parent:parent(), parent)	-- Remove the parent

		if child:tag() == 'assessmentStatement' or 'compoundStatement' then
			return
		else
			make_binary_tree (child, ncl)
		end

	-- In case parent has exactly two children.
	elseif #parent == 2 then

		-- Both child elements' TAG is equal to parent's TAG, assessmentStatement must be added to parent.
		if parent[1]:tag() == parent:tag() and parent[2]:tag() == parent:tag() then
			stat = xml.new('assessmentStatement')
			stat.comparator='eq'
			attr[1] = xml.new('attributeStatement')
			attr[1].role = aux.gen_id(ncl)
			attr[1].eventType = 'attribution'
			attr[2] = xml.new('attributeStatement')
			attr[2].role = aux.gen_id(ncl)
			attr[2].eventType = 'attribution'
			stat:insert(attr[1])
			stat:insert(attr[2])
			parent:insert(stat)
		elseif parent[1]:tag() == root[parent:tag()] or parent[2]:tag() == root[parent:tag()] then
			-- Nothing to do. Already a binary compound parent.
		else

			for index, element in ipairs(parent) do

				if element:tag() == ('assessmentStatement' or 'compoundStatement') then
					child = xml.remove(parent, element)
				elseif element:tag() == parent:tag() then
					if child then
						element:insert(child)
					end
				end

				if child and child:parent() == nil and index == 2 then
					parent[1]:insert(child)
				end

			end

		end

		for index, element in ipairs(parent) do
			if element:tag() == parent:tag() then
				make_binary_tree (element, ncl)
			end
		end

	-- In case parent has more than two children.
	else
		local counter = 0

		-- If parent has exactly three children, then parent might be a ternary or binary compound element.
		if #parent == 3 then
			for index, element in ipairs(parent) do
				if element:tag() == parent:tag() then
					counter = counter +1
				end
			end

			-- Already in the correct structure, two compound elements of TAG equals to parent's TAG
			-- and one assessmentStatement or one compoundStatement.
			if counter == 2 then
				goto exception
			end
		end

		-- For each parent, a new element is created using the same TAG and operator as parent's.
		root[parent:tag()] = xml.new(parent:tag())
		root[parent:tag()].operator = parent.operator or (root[parent:tag()] .. '_operator')

		for index, element in ipairs(parent) do
			-- Gather compound elements into a compound element.
			if #parent == 1 and element:tag() == ('compoundStatement' or 'assessmentStatement') then
				child = xml.remove(root[parent:tag()], 1)
				parent:insert(child)
			elseif element:tag() == parent:tag() then
				child = xml.remove(parent, element)
				root[parent:tag()]:insert(child)
			elseif element:tag() == 'assessmentStatement' then
				-- Gather assessment statements into a compound statement.
				if root['compoundStatement'] == nil then
					root['compoundStatement'] = xml.new('compoundStatement')
					root['compoundStatement'].operator = 'and'
					parent:insert(root['compoundStatement'])
				end

				child = xml.remove(parent, element)
				root['compoundStatement']:insert(child)
			elseif element:tag() == 'compoundStatement' then
				if root['compoundStatement'] then
					for index, assessment in ipairs(root['compoundStatement']) do
						assessment = xml.remove(root['compoundStatement'], assessment)
						element:insert(assessment)
					end
					xml.remove(parent, root['compoundStatement'])
				end

			end

		end

		parent:insert(root[parent:tag()])

		-- After this treatment, parent might become a parent which has two children or one children or none.
		-- There is need of using make_binary_tree (parent, ncl) again.
		make_binary_tree (parent, ncl)

		::exception::

		for index, element in ipairs(parent) do
			if element:tag() == parent:tag() then
				make_binary_tree (element, ncl)
			end
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
   local stat

	for conn in ncl:gmatch('causalConnector') do

	-- Turns unary elements (i.e. simpleCondition) into binary ones by adding
	-- the unary into a new compound element together with a new tautological
	-- assessment statement.

		for tag_cond in conn:gmatch('simpleCondition') do
			parent = tag_cond:parent()
			if #parent == 2 then
				if parent[1]:tag() == tag_cond:tag() and parent[2]:tag() == ('assessmentStatement' or 'compoundStatement') then
					-- It's already a binary compound. Nothing to do.
					goto finish
				elseif parent[2]:tag() == tag_cond:tag() and parent[1]:tag() == ('assessmentStatement' or 'compoundStatement') then
					-- It's already a binary compound. Nothing to do.
					goto finish
				else
					-- Procedure must be carried on.
				end
			end

			compound=xml.new('compoundCondition')
			compound.operator='and'
			stat=xml.new('assessmentStatement')
			stat.comparator='eq'
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

			::finish::
		end

		-- Breakage procedure: creates a chain of binary compound conditions.
		for compound in conn:gmatch('^compound[AC].*$', nil, nil, 4) do
			if compound:parent() == conn then
				make_binary_tree (compound, ncl)
			end
		end

		-- Updates all binds of the respective links after breakage procedure.
		for parent_tag in conn:gmatch('^compound[ACS].*$', nil, nil, 4) do
			for link in ncl:gmatch('link') do
				if link.xconnector == conn.id then
					for tag in parent_tag:gmatch('^simple[AC].*$', nil, nil, 4) do
						for bind in link:gmatch('bind') do
							if bind.role == tag.role then
								for attr in tag:parent():parent():gmatch('attributeStatement') do

									-- Avoid creating binds referring to an attributeStatement already referred by another bind.
									for review_bind in link:gmatch('bind') do
											if review_bind.role == attr.role then
												goto continue
											end
									end

									if counter == 2 then
										property=xml.new ('property')
										property.name=aux.gen_id (ncl)
										link:parent():insert(property)
										counter=0
									end

									new_bind=xml.new('bind')

									if (link:parent()).id then
										new_bind.component=(link:parent()).id
									end

									new_bind.role = attr.role
									new_bind.interface = property.name
									counter = counter+1
									link:insert(new_bind)
								end
							end

							::continue::
						end
					end
				end
			end
		end
	end

	print (ncl)
	return ncl

end


return filter
