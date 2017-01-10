--[[ filter.prenorm3 -- Third pre-normalization step.
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

--- XML filter
-- @module prenorm3

local filter = {}

local aux = require ('dietncl.nclaux')
_ENV = nil

---
-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM3, implements the third pre-normalization
-- step: It guarantees that the compound conditions and compound actions of
-- all connectors have no "delay" attribute.
--
-- Depends: PRENORM1.
-- @param ncl NCL document.
-- @return NCL document.

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
      delay = delay + aux.timetoseconds (x.delay or '0s')
      x.delay = nil
   end
   for i=1,#x do
      remove_compound_delay_tail (x[i], delay)
   end
end

function filter.apply (ncl)
   for conn in ncl:gmatch ('causalConnector') do
      for x in conn:children () do
         remove_compound_delay_tail (x, 0)
      end
   end
   return ncl
end

return filter
