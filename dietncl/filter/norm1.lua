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

        if link == nil and #conn == 0 then
            link = ncl:match('link', 'xconnector', conn.id)
            xml.remove (link:parent(), link)
            xml.remove (conn:parent(), conn)
        else
            local parent = link:parent()
            local copy = link:clone()
            copy.id = conn.id
            parent:insert (copy)
            for attr in conn:gmatch ('attributeStatement') do
                local new_bind = xml.new ('bind')
                new_bind.role = attr.role
                local property = copy:parent():match('property')
                if not property then
                    property = xml.new ('property')
                    property.name = aux.gen_id (ncl)
                end
                new_bind.interface = property.name
                if copy:parent().id then
                    new_bind.component = copy:parent().id
                end
            end
        end

end

local function break_ternary_compounds (ncl, base, connector, parent)

    if #parent == 3 then

        local statement
        local child_list = {}
        local conn = {}

        for i, child in ipairs (parent) do
            child_list[i] = child
            if child:tag() == 'assessmentStatement' then
                statement = xml.new ('compoundStatement')
            end
        end

        for index, child in ipairs (child_list) do
            if child:tag() == 'assessmentStatement' or child:tag() == 'compoundStatement' then
                statement = xml.remove (child:parent(), child)
                child = nil
            end
        end

        if parent.operator == 'or' then
            for index, child in ipairs (child_list) do
                if child:tag () == 'compoundCondition' then
                    conn[index] = xml.new ('causalConnector')
                    conn[index].id = aux.gen_id (ncl)
                    base:insert (conn[index])
                    local link = ncl:match ('link', 'xconnector', connector.id)
                    child = xml.remove (parent, child)
                    local copy = statement:clone()
                    if #child == 2 and child:match('simpleCondition') then
                        local compound_stat = xml.new ('compoundStatement')
                        compound_stat.operator = 'and'

                        if statement:tag() == 'compoundStatement' then
                            for i, stat in ipairs (statement) do
                                stat = xml.remove (statement, stat)
                                compound_stat:insert (stat)
                            end
                            xml.remove(parent, statement)
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
                end
            end
        end

        xml.remove (parent:parent(), parent)

        for index, connectors in ipairs (conn) do
            for count, element in ipairs (connectors) do
                if element:tag() == 'compoundCondition'  then
                    break_ternary_compounds (ncl, base, connectors, element)
                end
            end
        end

    elseif parent.operator == 'and' and #parent == 3 then


    elseif #parent == 2 then
        -- TODO: Fix make_ternary_compounds (parent[1]), parent[1] is not being accepted.
        if parent[1] == 'simpleCondition' or parent[2] == 'simpleCondition' then
            return
        elseif parent[1]:tag() == 'compoundCondition' then
            break_ternary_compounds (ncl, base, conn, parent[1])
        elseif parent[2]:tag() == 'compoundCondition' then
            break_ternary_compounds (ncl, base, conn, parent[2])
        end
    end


end


function filter.apply (ncl)

    for conn in ncl:gmatch ('causalConnector') do
        local compound = conn:match ('compoundCondition')

        if compound[1]:tag() == 'simpleCondition' or compound[2]:tag() == 'simpleCondition' then
            goto keep
        end

        for index, parent in ipairs (conn) do
            break_ternary_compounds (ncl, conn:parent(), conn, parent)
        end

        update_binds (ncl, conn)

        ::keep::

    end

    print(ncl)

    return ncl

end

return filter
