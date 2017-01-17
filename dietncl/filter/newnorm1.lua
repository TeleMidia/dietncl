--[[ norm1.lua -- First Normal Form implementation.
     Copyright (C) 2013-2017 PUC-Rio/Laboratorio TeleMidia

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


local filter = {}

local ipairs = ipairs

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- Guarantees that for any ABS program S there is an equivalent program S'
-- such that each link L of S' has condition and action degrees zero.
--
-- Dependencies: `dietncl.filter.prenorm5`
-- @module dietncl.filter.norm1
---

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

---
-- The NORM1-2 filters simplify links and connectors from a given NCL
-- document. This filter NORM1, under the First Normal Form (NF1), guarantees
-- that for any ABS program S there is an equivalent program S' such that each link L
-- of S' has condition and action degrees zero.
-- @param ncl NCL document (root element).
-- @return the modified NCL document (root element).
---
function filter.apply (ncl)
end

return filter
