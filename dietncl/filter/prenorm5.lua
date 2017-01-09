--[[ prenorm5.lua -- Fifth pre-normalization step.
     Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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

--- XML filter
-- @module prenorm5

local filter = {}

local ipairs = ipairs

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- Insert a tautological statement to turn a compound element into a binary one.
--

local function insert_tautological_statement (ncl, conn, parent)
    local attr = {}
    local stat
    local new_bind
    local property

    stat = xml.new ('assessmentStatement')
    stat.comparator = 'eq'
    attr[1] = xml.new ('attributeStatement')
    attr[1].role = aux.gen_id (ncl)
    attr[1].eventType = 'attribution'
    attr[2] = xml.new ('attributeStatement')
    attr[2].role = aux.gen_id(ncl)
    attr[2].eventType = 'attribution'
    stat:insert (attr[1])
    stat:insert (attr[2])
    parent:insert (stat)

    for link in ncl:gmatch ('link', 'xconnector', conn.id) do

        property = link:parent():match ('property')

        if property == nil or property:parent() ~= link:parent() then
            property = xml.new ('property')
            property.name = aux.gen_id (ncl)
            link:parent():insert (property)
        end

        for index, attribute in ipairs (attr) do
            new_bind = xml.new ('bind')

            if (link:parent()).id then
                new_bind.component = (link:parent()).id
            end

            new_bind.role = attribute.role
            new_bind.interface = property.name
            link:insert (new_bind)
        end

    end

end

---
-- Make sure that every leaf of the tree is a binary compound and every branch of the tree is a ternary compounds.
--

local function make_ternary_tree (ncl, conn, parent)
   local child
   local exclude = {'compoundStatement', 'assessmentStatement', 'simpleCondition', 'simpleAction', 'attributeStatement',
                    compoundCondition = 'simpleCondition',
                    compoundAction = 'simpleAction'}

   local root={compoundCondition_operator = 'and',
                compoundAction_operator = 'par',
                compoundStatement_operator = 'and',
                [1] = 'compoundCondition',              [2] = 'compoundAction',              [3] = 'compoundStatement'}

    -- Returns function in case parent's length is zero (there are no child elements).
    if #parent == 0 then
        return
    end

    -- In case parent has exactly one child, parent's child must be removed from parent and then inserted into parent's parent.
    if #parent == 1 then
        child = xml.remove (parent, 1)          -- Remove child from parent and insert it into parent's parent
        parent:parent():insert (child)
        xml.remove (parent:parent(), parent)    -- Remove the parent

        if child:tag() == 'assessmentStatement' or child:tag() == 'compoundStatement' then
            return
        else
            make_ternary_tree (ncl, conn, child)
        end

    -- In case parent has exactly two children.
    elseif #parent == 2 then

        -- Both child elements' TAG is equal to parent's TAG, assessmentStatement must be added to parent.
        if parent[1]:tag() == parent:tag() and parent[2]:tag() == parent:tag() then
            insert_tautological_statement (ncl, conn, parent)
        elseif parent[1]:tag() == exclude[parent:tag()] or parent[2]:tag() == exclude[parent:tag()] then
            -- Nothing to do. Already a binary compound parent.
        else

            for index, element in ipairs (parent) do

                if element:tag() == 'assessmentStatement' or element:tag() == 'compoundStatement' then
                    child = xml.remove (parent, element)
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

        for index, element in ipairs (parent) do
            if element:tag() == parent:tag() then
                make_ternary_tree (ncl, conn, element)
            end
        end

    -- In case parent has more than two children.
    else
        local counter = 0

        -- If parent has exactly three children, then parent might be a ternary or binary compound element.
        if #parent == 3 then
            for index, element in ipairs (parent) do
                if element:tag() == parent:tag() then
                    counter = counter +1
                elseif element:tag() == exclude[parent:tag()] then
                    goto exception
                end
            end

            -- Already in the correct structure, two compound elements of TAG equals to parent's TAG
            -- and one assessmentStatement or one compoundStatement.
            if counter == 2 then
                goto exception
            end
        end

        -- For each parent, a new element is created using the same TAG and operator as parent's.
        root[parent:tag()] = xml.new (parent:tag())
        root[parent:tag()].operator = parent.operator or (root[parent:tag()] .. '_operator')

        for index, element in ipairs (parent) do
            -- Gather compound elements into a compound element.
            if #parent == 1 and (element:tag() == 'compoundStatement' or element:tag() == 'assessmentStatement') then
                child = xml.remove (root[parent:tag()], 1)
                parent:insert (child)
            elseif element:tag() == parent:tag() then
                child = xml.remove (parent, element)
                root[parent:tag()]:insert(child)
            elseif element:tag() == 'assessmentStatement' then
                -- Gather assessment statements into a compound statement.
                if root['compoundStatement'] == nil then
                    root['compoundStatement'] = xml.new ('compoundStatement')
                    root['compoundStatement'].operator = 'and'
                    parent:insert (root['compoundStatement'])
                end

                child = xml.remove (parent, element)
                root['compoundStatement']:insert (child)
            elseif element:tag() == 'compoundStatement' then
                if root['compoundStatement'] then
                    for index, assessment in ipairs (root['compoundStatement']) do
                        assessment = xml.remove (root['compoundStatement'], assessment)
                        element:insert (assessment)
                    end
                    xml.remove (parent, root['compoundStatement'])
                end

            end

        end

        parent:insert (root[parent:tag()])

        -- After this treatment, parent might become a parent which has two children or one child or none.
        -- It's necessary to apply make_binary_tree (parent, ncl) once again.
        make_ternary_tree (ncl, conn, parent)

        ::exception::

        for index, element in ipairs (parent) do
            if element:tag() == parent:tag() then
                make_ternary_tree (ncl, conn, element)
            end
        end

    end

end

---
-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM5, implements the fifth pre-normalization
-- step: It guarantees that the compound actions and compound statements of
-- all connectors are binary and its compound conditions are either binary
-- or ternary, and have exactly one child (assessment or compound)
-- statement.
--
-- Depends: PRENORM1.
-- @param ncl NCL document.
-- @return NCL document.

function filter.apply (ncl)
   local compound
   local parent

    for conn in ncl:gmatch('causalConnector') do

    -- Turns unary elements (i.e. simpleCondition) into binary ones by adding
    -- the unary into a new compound element together with a new tautological
    -- assessment statement.

        for tag_cond in conn:gmatch('simpleCondition') do
            parent = tag_cond:parent()
            if #parent == 2 then
                if parent[1]:tag() == tag_cond:tag() and (parent[2]:tag() == 'assessmentStatement' or parent[2]:tag() == 'compoundStatement') then
                    -- It's already a binary compound. Nothing to do.
                    goto finish
                elseif parent[2]:tag() == tag_cond:tag() and (parent[1]:tag() == 'assessmentStatement' or parent[1]:tag() == 'compoundStatement') then
                    -- It's already a binary compound. Nothing to do.
                    goto finish
                else
                    -- Procedure must be carried on.
                end
            end

            compound = xml.new('compoundCondition')
            compound.operator = 'and'
            (tag_cond:parent()):insert (compound)
            tag_cond = xml.remove (tag_cond:parent(), tag_cond)
            compound:insert (tag_cond)

            insert_tautological_statement (ncl, conn, compound)

            ::finish::
        end

        -- Breakage procedure: creates a chain of binary compound conditions.
        for compound in conn:gmatch ('^compound[AC].*$', nil, nil, 4) do
            if compound:parent() == conn then
                make_ternary_tree (ncl, conn, compound)
            end
        end

    end

    return ncl

end


return filter
