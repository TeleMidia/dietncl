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

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

local function include_tautological (action, element, conn, new_connector, ncl)
    local property
    local new_action

    if element.operator == 'and' and element:tag() == 'compoundCondition' then

        new_action = xml.new ('simpleAction')
        new_action.role = 'set'
        new_action.value = '1'

        if action then
            local copy = action:clone()
            copy:insert (new_action)
            new_connector:insert (copy)
            goto out
        else
            new_connnector:insert (new_action)
        end

    end

    if action then
        new_connector:insert (action:clone())
    end

    ::out::

end


function filter.apply (ncl)
    local condition = true

    while condition == true do
        local conn_list = {ncl:match ('causalConnector')}

        condition = false
        for index, conn in ipairs (conn_list) do
            local first_stat
            local new_connector


            for first in conn:gmatch ('compoundStatement') do
                if first:parent() == conn then
                    first_stat = xml.remove (first:parent(), first)
                end
            end

            if first_stat == nil then
                for first in conn:gmatch ('assessmentStatement') do
                    if first:parent() == conn then
                        first_stat = xml.remove (first:parent(), first)
                    end
                end
            end

            local comp = {conn:match ('compoundCondition')}
                local action
                if #comp > 0 then
                    for action_root in conn:gmatch ('compoundAction') do
                        if action_root:parent() == conn then
                            action = xml.remove (action_root:parent(), action_root)
                        end
                    end

                    if action == nil then
                        for action_root in conn:gmatch ('simpleAction') do
                            if action_root:parent() == conn then
                                action = xml.remove (action_root:parent(), action_root)
                            end
                        end
                    end
                end

                for i, element in ipairs (comp) do
                    if first_stat and #element == 2 then
                        if first_stat:tag() == 'assessmentStatement' then
                            element:insert (first_stat:clone())
                        elseif first_stat:tag() == 'compoundStatement' then
                            for index, supreme_stat in ipairs (first_stat) do
                                supreme_stat = xml.remove (supreme_stat:parent(), supreme_stat)
                                element:insert (supreme_stat)
                            end
                        end
                    end
                end

                for i, element in ipairs (comp) do
                    if #element >= 3 then
                        local temp_stat = {}
                        local new_compound

                        local count = 1
                        for child in element:gmatch ('assessmentStatement') do
                            if child:parent() == element or (child:parent():parent() == element and child:parent():tag() == 'compoundStatement') then
                                temp_stat[count] = xml.remove (child:parent(), child)
                                if count > 1 then
                                    if not new_compound then
                                        new_compound = xml.new ('compoundStatement')
                                        new_compound.operator = 'and'
                                    end
                                    new_compound:insert (temp_stat[count])
                                end
                                count = count + 1
                            end
                        end

                        if new_compound then
                            new_compound:insert (temp_stat[1])
                        end


                        for child in element:gmatch ('compoundCondition') do
                            if child:parent() == element then
                                local track = 1
                                local temp_comp = xml.remove (child:parent(), child)
                                new_connector = xml.new ('causalConnector')
                                new_connector.id = aux.gen_id (ncl) .. '1'
                                new_connector:insert (temp_comp)
                                conn:parent():insert (new_connector)

                                include_tautological (action, element, conn, new_connector, ncl)

                                if new_compound then
                                    local copy = new_compound:clone()
                                    for assessmt in temp_comp:gmatch ('assessmentStatement') do
                                        if assessmt:parent() == temp_comp or (assessmt:parent():parent() == temp_comp and assessmt:parent():tag() == 'compoundStatement') then
                                            local root = assessmt:parent()
                                            local transfer = xml.remove (assessmt:parent(), assessmt)
                                            if #root == 0 and root ~= temp_comp then
                                                xml.remove (root:parent(), root)
                                            end
                                            copy:insert (transfer)
                                        end
                                    end
                                    temp_comp:insert (copy)

                                elseif temp_stat[1] then
                                    local new_compound = xml.new ('compoundStatement')
                                    new_compound.operator = 'and'
                                    for assessmt in temp_comp:gmatch ('assessmentStatement') do
                                        if assessmt:parent() == temp_comp or (assessmt:parent():parent() == temp_comp and assessmt:parent():tag() == 'compoundStatement') then
                                            local root = assessmt:parent()
                                            local transfer = xml.remove (assessmt:parent(), assessmt)
                                            if #root == 0 and root ~= temp_comp then
                                                xml.remove (root:parent(), root)
                                            end
                                            new_compound:insert (transfer)
                                        end
                                    end

                                    if action then
                                        new_connector:insert (action:clone())
                                    end

                                    if #new_compound > 0 then
                                        new_compound:insert (temp_stat[1]:clone())
                                        temp_comp:insert (new_compound:clone())
                                    else
                                        temp_comp:insert (temp_stat[1]:clone())
                                    end

                                end

                                for link in ncl:gmatch ('link', 'xconnector', conn.id) do
                                    local new_link = link:clone()
                                    new_link.xconnector = new_connector.id
                                    link:parent():insert (new_link)

                                    for bind in new_link:gmatch('bind') do
                                        for simple in new_connector:gmatch ('simpleCondition', 'role', bind.role) do
                                            goto _next
                                        end

                                        for simple in new_connector:gmatch ('simpleAction', 'role', bind.role) do
                                            goto _next
                                        end

                                        for simple in new_connector:gmatch ('attributeStatement', 'role', bind.role) do
                                            goto _next
                                        end

                                        xml.remove (bind:parent(), bind)
                                        ::_next::
                                    end

                                end

                            end
                        end

                        for link in ncl:gmatch ('link', 'xconnector', conn.id) do
                            xml.remove (link:parent(), link)
                        end

                        condition = true

                        element = xml.remove (element:parent(), element)
                    elseif i == #comp and action then
                        conn:insert (action)
                    end
                if #conn == 0 then
                    xml.remove (conn:parent(), conn)
                end
                break
            end

        end
    end

    for conn in ncl:gmatch ('causalConnector') do
        for trigger in conn:gmatch ('simpleAction', 'role', 'set') do
            for link in ncl:gmatch ('link', 'xconnector', conn.id) do
                local property = xml.new ('property')
                property.name = aux.gen_id (ncl) .. '2'
                property.value = 0
                link:parent():insert (property)
                local new_bind = xml.new ('bind')
                new_bind.role = trigger.role
                new_bind.interface = property.name
                if link:parent().id then
                    new_bind.component = link:parent().id
                end
                link:insert (new_bind)
            end
        end
    end

    return ncl

end

return filter
