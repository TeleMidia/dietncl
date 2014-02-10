--[[ norm1.lua -- First Normal Form implementation.
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

-- The NORM1-2 filters simplify links and connectors from a given NCL
-- document. This filter NORM1, under the First Normal Form (NF1), guarantees
-- that for any ABS program S there is an equivalent program S' such that each link L
-- of S' has condition and action degrees zero.
--
-- Depends: PRENORM5.

local filter = {}

local ipairs = ipairs
local print = print

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- In case of ternary compound, an equivalent
--

local function update_binds (ncl, conn, link)
        
        if link == nil then
            link = ncl:match('link', 'xconnector', conn.id)
            if link then
                xml.remove (link:parent(), link)
            end
            xml.remove (conn:parent(), conn)
            
        else
            local parent = link:parent()
            local new_link = xml.new ('link')
	    new_link.xconnector = conn.id
            parent:insert (new_link)
	    for comp in conn:gmatch('simpleCondition') do
		local bind = link:match ('bind', 'role', comp.role)
		if bind then
			bind = xml.remove (bind:parent(), bind)
			new_link:insert (bind)
		end
	    end
	    for comp in conn:gmatch('simpleAction') do
		local bind = link:match ('bind', 'role', comp.role)
		if bind then
			bind = xml.remove (bind:parent(), bind)
			new_link:insert (bind)
		end
	    end
	     for attr in conn:gmatch ('attributeStatement') do
		local new_bind = xml.new ('bind')
		new_bind.role = attr.role
		local property = new_link:parent():match('property')
		if not property then
			property = xml.new ('property')
			property.name = aux.gen_id (ncl)
		end
		new_bind.interface = property.name
		if new_link:parent().id then
			new_bind.component = new_link:parent().id
		end
		new_link:insert (new_bind)
            end

        end

end

local function break_ternary_compounds (ncl, base, connector, parent, action)
    local statement
    local stat_list = {}
    local i = 1
    
    for stat in parent:gmatch('compoundStatement') do
        if stat:parent() == parent then
            stat_list[i] = stat
            i = i + 1
        end
    end
        
    if #stat_list == 1 then
        for stat in parent:gmatch('assessmentStatement') do
            if stat:parent() == parent then
		stat = xml.remove (parent, stat)
                stat_list[1]:insert (stat)
            end
        end
    elseif #stat_list == 2 then
        for index, element in ipairs (stat_list[1]) do
            element = xml.remove (stat_list[1], element)
            stat_list[2]:insert (element)
        end
    end
        
    local i = 1
    
    for stat in parent:gmatch('assessmentStatement') do
        if stat:parent() == parent then
            stat_list[i] = stat
            i = i + 1
        end
    end
        
    if #stat_list > 1 then
        local stat_compound = xml.new ('compoundStatement')
        stat_compound.operator = 'eq'
        for index, stat in ipairs (stat_list) do
            stat = xml.remove (stat:parent(), stat)
	    local copy = stat:clone()
            stat_compound:insert (copy)
        end
    end
    
    if #parent == 3 then

        local statement
        local child_list = {}
        local conn = {}

        for i, child in ipairs (parent) do
            child_list[i] = child
        end
        
        for index, child in ipairs (child_list) do
            if child:tag() == 'assessmentStatement' or child:tag() == 'compoundStatement' then
                statement = xml.remove (child:parent(), child)
                child = nil
            end
        end
        
        if parent.operator == 'or' then
            for index, child in ipairs (child_list) do
                if child:tag () == 'compoundCondition' and #child == 2 then
                    conn[index] = xml.new ('causalConnector')
                    conn[index].id = aux.gen_id (ncl)
                    if action then
                        local copy = action:clone ()
                        conn[index]:insert (copy)
                    end
                    base:insert (conn[index])
                    local link = ncl:match ('link', 'xconnector', connector.id)
                    child = xml.remove (parent, child)
                    local copy = statement:clone()
                    if #child == 2 and child:match('simpleCondition') and statement then
                        local compound_stat = xml.new ('compoundStatement')
                        compound_stat.operator = 'and'

                        if statement:tag() == 'compoundStatement' then
                            for i, stat in ipairs (statement) do
                                stat = xml.remove (statement, stat)
                                compound_stat:insert (stat)
                            end
                        end

                        compound_stat:insert (copy)
                        copy = child:match ('assessmentStatement')
                        copy = xml.remove (child, copy)
                        compound_stat:insert (copy)
                        child:insert (compound_stat)
                    else
                        child:insert (copy)
                    end
                    conn[index]:insert (child)
                    if link then
                        update_binds (ncl, conn[index], link)
                    end
                elseif child:tag () == 'compoundCondition' and #child == 3 then
			for index, element in ipairs (child) do
				local assess
				if element:tag() == 'compoundStatement' or element:tag() == 'assessmentStatement' then
					assess = xml.remove (element:parent(), element)
				end
				if assess then
					for i, comp in ipairs (child) do
						if comp:tag() == 'compoundCondition' then
							local copy = assess:clone()
							comp:insert (copy)
						end
					end
				end
			end
			 break_ternary_compounds (ncl, base, connector, child[1], action['master'])
			 break_ternary_compounds (ncl, base, connector, child[2], action['master'])
		end
            end
        end
    
        for index, connectors in ipairs (conn) do
            for count, element in ipairs (connectors) do
                if element:tag() == 'compoundCondition'  then
                    break_ternary_compounds (ncl, base, connector, element, action['master'])
                end
            end
        end

    elseif parent.operator == 'and' and #parent == 3 then


    elseif #parent == 2 then
        -- TODO: Fix make_ternary_compounds (parent[1]), parent[1] is not being accepted.
        if parent[1] == 'simpleCondition' or parent[2] == 'simpleCondition' then
            return
        elseif parent[1]:tag() == 'compoundCondition' then
            break_ternary_compounds (ncl, base, connector, parent[1], action)
        elseif parent[2]:tag() == 'compoundCondition' then
            break_ternary_compounds (ncl, base, connector, parent[2], action)
        end
    end


end


function filter.apply (ncl)

    for conn in ncl:gmatch ('causalConnector') do
        
        local root_statement = {}
        
        root_statement = {conn:match ('compoundStatement')}
	for index, element in ipairs (root_statement) do
            if element:parent() == conn then
                root_statement['compoundStatement'] = xml.remove(element:parent(), element)
            end
	end
        
        if root_statement['compoundStatement'] == nil then
	    root_statement = {conn:match ('assessmentStatement')}
            for index, element in ipairs (root_statement) do
                if element:parent() == conn then
                    root_statement['assessmentStatement'] = xml.remove(element:parent(), element)
                end
            end
        end
        
        local action = {conn:match ('compoundAction')}
	for index, element in ipairs (action) do
            if element:parent() == conn then
                action['master'] = xml.remove (element:parent(), element)
            end
        end
        
        if action['master'] == nil then
	action = {conn:match ('simpleAction')}
            for index, element in ipairs (action) do
                if element:parent() == conn then
                    action['master'] = xml.remove (element:parent(), element)
                end
            end
        end
        

      print(action['master'])
       print(root_statement['assessmentStatement'])
        
        for parent in conn:gmatch ('compoundCondition') do
            if parent:parent() == conn then
                if root_statement['assessmentStatement'] then
                    local comp_stat = xml.new ('compoundStatement')
                    comp_stat.operator = 'eq'
                    comp_stat:insert (root_statement['assessmentStatement'])
                    parent:insert (comp_stat)
                elseif root_statement['compoundStatement'] then
                    parent:insert (root_statement['compoundStatement'])
                end
                break_ternary_compounds (ncl, conn:parent(), conn, parent, action['master'])
            end
        end

        update_binds (ncl, conn)

    end

   print(ncl)

    return ncl

end

return filter
