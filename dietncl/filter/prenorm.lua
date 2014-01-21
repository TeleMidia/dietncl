-- prenorm.lua -- Simplifies links and connectors.
-- Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
--
-- This file is part of DietNCL.
--
-- DietNCL is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DietNCL is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DietNCL.  If not, see <http://www.gnu.org/licenses/>.


                          -- The PRENORM Filter --

-- The "prenorm" filter simplifies the links and connectors from a given NCL
-- document.  More specifically, it makes sure that the document satisfies
-- the following five restrictions.
--
--  (1) Each connector is referenced by exactly one link.
--
--  (2) All connectors and links contain no link, bind, or connector
--      parameters, i.e., no <linkParam>, <bindParam>, or <connectorParam>
--      elements -- except if the infamous "pega dali" is used.
--
--  (3) The compound conditions and compound actions of all connectors have
--      no "delay" attribute.
--
--  (4) The simple conditions and simple actions of all connectors are
--      referenced by exactly one bind in the associated links.
--
--  (5) The compound actions and compound statements of all connectors are
--      binary and its compound conditions are either binary or ternary, and
--      have exactly one child (assessment or compound) statement.
--
-- This filter depends on the "import" filter, i.e., it assumes that the
-- given document has no import declaration.

local filter = {}

local assert = assert
local ipairs = ipairs
local print = print
local tonumber = tonumber
local type = type

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

-- Makes sure that each connector is referenced by exactly one link.
-- Returns the updated document.

local function make_bijection (ncl)
   for conn in ncl:gmatch ('causalConnector') do
      local list = {ncl:match ('link', 'xconnector', conn.id)}

      if #list == 0 then
         xml.remove (conn:parent (), conn)
         goto continue
      end

      if #list == 1 then
         goto continue          -- nothing to do
      end

      for i=1,#list-1 do
         local parent = conn:parent ()
         local dup = conn:clone ()

         dup.id = aux.gen_id (ncl)
         list[i].xconnector = dup.id
         parent:insert (dup)
      end

      :: continue ::
   end
   return ncl
end

-- Removes all parameters from links and connectors.
-- This function assumes that NCL satisfies restriction (1).

local function remove_params (ncl)
   for conn in ncl:gmatch ('causalConnector') do

      local dont_delete = {} -- connector parameters that we can't delete
      local link             -- link associated with connector conn

      link = ncl:match ('link', 'xconnector', conn.id)

      for bind in link:gmatch ('bind') do

         local bindref = conn:match (nil, 'role', bind.role)
         if bindref == nil then
            goto continue       -- nothing to do ("pega dali")
         end

         for k,v in bindref:attributes () do

            if v:sub(1,1) ~= '$' then
               goto continue    -- nothing to do
            end

            local name = v:sub (2)
            local connparam = conn:match ('connectorParam', 'name', name)
            if connparam == nil then
               goto continue    -- nothing to do
            end

            -- Get the associated bind-parameter.

            local bindparam
            if #bind == 0 then
               local p = link:match ('linkParam', 'name', name)
               if p == nil then
                  goto continue -- nothing to do
               end
               bindparam = xml.new ('bindParam')
               bindparam.name = p.name
               bindparam.value = p.value
               bind:insert (bindparam)
            else
               bindparam = bind[1]
            end

            -- If is an infamous "pega-dali", then don't delete.

            if bindparam.value:sub (1,1) == '$' then
               dont_delete[connparam] = true
               goto continue
            end

            -- Replace bind's value for connector's value and remove the
            -- bind-parameter.

            bindref[k] = bindparam.value
            bind:remove (bindparam)

            :: continue ::
         end

         :: continue ::
      end

      -- Remove the connector parameters from conn that are not used by some
      -- infamous "pega-dali".

      for p in conn:gmatch ('connectorParam') do
         if dont_delete[p] then
            goto continue       -- do nothing
         end
         conn:remove (p)
         :: continue ::
      end

      -- Remove all link-parameters from link.

      for p in link:gmatch ('linkParam') do
         link:remove (p)
      end
   end

   return ncl
end

-- Removes the "delay" attribute from compound conditions and actions.
-- This function assumes that NCL satisfies restriction (2).

local function remove_compound_delay_tail (x, delay)
   if x:tag () == 'connectorParam' then
      return                    -- nothing to do
   end
   if x:tag () == 'simpleCondition' or x:tag () == 'simpleAction' then
      if delay > 0 then
         x.delay = (delay + aux.timetoseconds (x.delay or '0s'))..'s'
      end
      return                    -- basis
   end
   if x.delay ~= nil then
      delay = delay + (aux.timetoseconds (x.delay or '0s'))
      x.delay = nil
   end
   for i=1,#x do
      remove_compound_delay_tail (x[i], delay)
   end
end

local function remove_compound_delay (ncl)
   for conn in ncl:gmatch ('causalConnector') do
      for x in conn:children () do
         remove_compound_delay_tail (x, 0)
      end
   end
   return ncl
end

-- This function expands alias, expressing attributes eventType, actionType
-- and transition of all simpleConditions and simpleActions whose roles are
-- reserved action/condition role values associated to event state machines.

local function expand_alias(conn, ...)
	local event_list={}

	-- Event Types listed by role.
	-- Simple conditions Event Types.
	event_list['onBegin']='presentation'
	event_list['onEnd']='presentation'
	event_list['onAbort']='presentation'
	event_list['onPause']='presentation'
	event_list['onResume']='presentation'
	event_list['onSelection']='selection'
	event_list['onBeginSelection']='selection'
	event_list['onEndSelection']='selection'
	event_list['onAbortSelection']='selection'
	event_list['onPauseSelection']='selection'
	event_list['onResumeSelection']='selection'
	event_list['onBeginAttribution']='attribution'
	event_list['onResumeAttribution']='attribution'
	event_list['onEndAttribution']='attribution'
	event_list['onPauseAttribution']='attribution'
	event_list['onAbortAttribution']='attribution'
	-- Simple actions Event Types.
	event_list['start']='presentation'
	event_list['stop']='presentation'
	event_list['abort']='presentation'
	event_list['pause']='presentation'
	event_list['resume']='presentation'
	event_list['set']='attribution'

	-- Transition Values (Simple Conditions) listed by role.
	local trans_list={}
	trans_list['onBegin']='starts'
	trans_list['onEnd']='stops'
	trans_list['onAbort']='aborts'
	trans_list['onPause']='pauses'
	trans_list['onResume']='resumes'
	trans_list['onSelection']='stops'
	trans_list['onBeginSelection']='starts'
	trans_list['onEndSelection']='stops'
	trans_list['onAbortSelection']='paborts'
	trans_list['onPauseSelection']='pauses'
	trans_list['onResumeSelection']='resumes'
	trans_list['onBeginAttribution']='starts'
	trans_list['onResumeAttribution']='resumes'
	trans_list['onEndAttribution']='stops'
	trans_list['onPauseAttribution']='pauses'
	trans_list['onAbortAttribution']='aborts'

	-- Action Types (simple Actions) listed by role.
	local action_list={}
	action_list['start']='start'
	action_list['stop']='stop'
	action_list['abort']='abort'
	action_list['pause']='pause'
	action_list['resume']='resume'
	action_list['set']='start'

	for z in conn:gmatch(...) do
		if event_list[z.role] then
			z.eventType=event_list[z.role]
			if trans_list[z.role] then
				z.transition=trans_list[z.role]
			else
				z.actionType=action_list[z.role]
			end
		end
	end

end

-- This function replace each simple condition (or action) that is referenced
-- by more than one bind by an equivalent compound condition (or action).

local function make_compound(conn, ...)

	local root
	local superior={}
	local str=...

	for x in conn:gmatch(...) do
			if not superior[x.eventType] and x.eventType and (x:parent())=='causalConnector' then
				if str=='simpleCondition' then
					root=xml.new('compoundCondition')
					root.operator='and'
					superior[x.eventType]=root
				elseif str=='simpleAction' and x.eventType then
					root=xml.new('compoundAction')
					root.operator='par'
					superior[x.eventType]=root
				end
				conn:insert(superior[x.eventType])

			end

			if superior[x.eventType] then
				x=xml.remove(x:parent(), x)
				superior[x.eventType]:insert(x)
			end

	end

end


-- This auxiliary function duplicates a simple condition or a simple action.
-- n represents the number os positions occupied by duplicates of a common
-- simple action/condition parent.

local function duplicator (bind, conn, ncl, n, ...)

	local roleTab={}
	local deter=...

    for x in conn:gmatch(...) do
		if x.role==bind.role then
			expand_alias(conn, ...)
			local duplicate = x:clone ()
			duplicate.role=aux.gen_id(ncl)
			bind.role=duplicate.role
			local parent = x:parent ()
			local x, pos =  parent:findchild (x)
			parent:insert (pos + n + 1, duplicate)
			n=n+1
		end
	end

	return n

end


-- Main function for restriction (4).
-- Make sure that simple conditions and simple actions of all connectors are referenced by exactly one bind in the associated links.
-- This function assumes that NCL satisfies restriction (3).


local function make_condition_action_bijection (ncl)
   for link in ncl:gmatch('link') do

      local conn = ncl:match ('causalConnector', 'id', link.xconnector)
      local roleTable={}
	  local nc=0
	  local na=0

      for bind in link:gmatch('bind') do

		if not roleTable[bind.role] then
			roleTable[bind.role]=0
		else
			roleTable[bind.role]=roleTable[bind.role]+1
			nc=duplicator(bind, conn, ncl, nc, 'simpleCondition')
			na=duplicator(bind, conn, ncl, na, 'simpleAction')
		end

	end

	make_compound(conn, 'simpleCondition')
	make_compound(conn,'simpleAction')

   end
end

-- This function updates the binds of links after insertion of the respective
-- simpleCondition has been inserted into a new compoundCondition.

local function update_binds(attrR1, attrR2, conn, ncl, cond)
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


-- This function turns unary elements (i.e. simpleCondition) into binary ones
-- by adding the unary into a new compound element together with a new tautological
-- assessment statement.

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

-- This function turns binary compound elements into ternary ones inserting them
-- into a new compound element together with a tautological statement.

local function correct_singularity(conn, ncl, test, counter, root, remain, ...)

	local stat
	local attr={}
	local cmtype={}
	cmtype['compoundCondition']='simpleCondition'
	cmtype['compoundAction']='simpleAction'

	if test<3 and counter==1 then
		remain=xml.remove(remain:parent(), remain)
		conn:insert(remain)
	elseif test<3 and test>0 and root:parent()==nil then
		conn:insert(root)
	elseif counter==1 and test>2 then
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
		for condition in conn:gmatch(cmtype[...]) do
			update_binds(attr[1].role, attr[2].role, conn, ncl, condition)
		end
	end

end

-- This function turns binary elements into ternary ones inserting them
-- into a new compound element.

local function turn_binary_ternary(conn, ncl, ...)
	local counter=2
	local test=0

	local root
	local remain

	for comp in conn:gmatch(...) do
		if counter==2 then
			if root then
				conn:insert(root)
			end
			counter=0
			root=xml.new(...)
			root.operator='and'
			remain=nil
		end

		remain=xml.remove(conn, comp)
		root:insert(remain)
		counter=counter+1
		test=test+1
	end

	correct_singularity(conn, ncl, test, counter, root, remain, ...)

end

-- Main function for restriction (5).

local function make_compound_tree(ncl)

	for conn in ncl:gmatch('causalConnector') do
		turn_unary_binary(conn, ncl, 'simpleCondition')
		turn_binary_ternary(conn, ncl, 'compoundCondition')
		turn_binary_ternary(conn, ncl, 'compoundAction')
		turn_binary_ternary(conn, ncl, 'compoundStatement')
	end

	print(ncl)

end




-- Exported functions.

function filter.apply (ncl)
   make_bijection (ncl)
   remove_params (ncl)
   remove_compound_delay (ncl)
   make_condition_action_bijection (ncl)
   make_compound_tree (ncl)
   return ncl
end

return filter
