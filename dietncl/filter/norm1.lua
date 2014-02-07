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

local function break_ternary_compounds (parent)
    
    
    if parent.operator == 'or' and #parent == 3 then
        
        local new_compound = {}
        local statement
        local child_list = {} 

        for i, child in ipairs (parent) do
            child_list[i] = child
        end
        
        for index, child in ipairs (child_list) do
            if child:tag() == 'assessmentStatement' or child:tag() == 'compoundStatement' then
                statement = xml.remove (child:parent(), child)
            end
        end
        
        for index, child in ipairs (child_list) do
            if child:tag () == 'compoundCondition' then
                new_compound[index] = xml.new ('compoundCondition')
                new_compound[index].operator = 'and'
                parent:insert(new_compound[index])
                child = xml.remove (parent, child)
                new_compound[index]:insert (child)
                local copy = statement:clone()
                new_compound[index]:insert (copy)
            end
        end

    elseif parent.operator == 'and' and #parent == 3 then
        

    elseif #parent <= 2 then
        -- TODO: Fix make_ternary_compounds (parent[1]), parent[1] is not being accepted.
        if parent[1] == 'simpleCondition' or parent[2] == 'simpleCondition' then
            return
        elseif parent[1]:tag() == 'compoundCondition' then
            break_ternary_compounds (parent[1])
        elseif parent[2]:tag() == 'compoundCondition' then
            break_ternary_compounds (parent[2])
        end
    end
    
    for index, child in ipairs (parent) do
        if child and child:tag() == 'compoundCondition' and child.operator == 'or' then
            break_ternary_compounds (child)
        end
    end

    for index, child in ipairs (parent) do
            if child[1] and child[1]:tag() == 'compoundCondition'  then
                break_ternary_compounds (child[1])
            end
        end
    
end


function filter.apply (ncl)
    local condition_stats = 1

    for conn in ncl:gmatch ('causalConnector') do
        break_ternary_compounds (conn)
    end
    
    return ncl

end

return filter

