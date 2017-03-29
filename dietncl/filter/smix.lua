--[[ filter.check_ncl -- Check NCL Document.
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

local print = print
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string

local filter = {}

_ENV = nil

---
-- Transform a micro NCL program into smix
--
-- @module dietncl.filter.smix
---

-- table that signifies the transitions between presentation event states,
-- its actions and the corresponding triggered condition.
local transitiontable = {
   ['onBegin'] = {'start'},
   ['onPause'] = {'pause'},
   ['onResume'] = {'resume'},
   ['onEnd'] = {'stop'},
   ['onAbort'] = {'abort'},

   ['start'] = {true, 'start'},
   ['pause'] = {true, 'pause'},
   ['resume'] = {true, 'resume'},
   ['stop'] = {true, 'stop'},
   ['abort'] = {true, 'abort'}
}

-- function that receives a bind and a xconnector as parameters and returns
-- the actionType given by it
local function get_action (ncl, bind, xconn)
   local cconn = ncl:match ('causalConnector', 'id', xconn)
   local transition, actionType

   for elt in cconn:gmatch ('simpleCondition') do
      transition = elt.transition
   end

   for elt in cconn:gmatch ('simpleAction') do
      actionType = elt.actionType
   end

   return transition, actionType
end

-- filteeeer
function filter.apply (ncl)
   local t = {}

   -- media table
   local medials = {}
   for elt in ncl:gmatch ('media') do
      medials [elt.id] = {uri = elt.src}
   end

   table.insert (t, medials)

   -- port table
   local list = {{'start', 'lambda'}}
   for elt in ncl:gmatch ('port') do
      local plist = {true, 'start', elt.component}
      table.insert (list, plist)
   end

   table.insert (t, list)
--------------------------
   for link in ncl:gmatch ('link') do
      local llist = {}

      local conn = ncl:match ('causalConnector', 'id', link.xconnector)
      if conn == nil then
         return error
      end

      local cond = conn:match ('simpleCondition')
      local act = conn:match ('simpleAction')

      -- Add transition table to llist
      local bind = ncl:match ('bind', 'role', cond.role)
      local blist = {cond.transition:sub (1, -2), bind.component}
      table.insert (llist, blist)

      -- Add action table to llist
      for bind in link:gmatch ('bind', 'role', act.role) do
         blist = {true, act.actionType, bind.component}
         table.insert (llist, blist)
      end

      table.insert (t, llist)
   end
--------------------------
   return t
end

return filter
