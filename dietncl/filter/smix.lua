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
local type = type
local filter = {}

_ENV = nil

---
-- Transform a micro NCL program into smix
--
-- @module dietncl.filter.smix
---

-- table that signifies the transitions between presentation event states,
-- its actions and the corresponding triggered condition.
local transition = {
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

-- filteeeer
function filter.apply (ncl)
   local t = {}
   local medials = {}

   for elt in ncl:gmatch ('media') do
      medials [elt.id] = {[uri] = elt.src}
   end

   table.insert (t, medials)

   local list = {{'start', 'lambda'}}
   for elt in ncl:gmatch ('port') do
      local plist = {}

      for k, v in ipairs (transition['start']) do
         plist[k] = v
      end

      table.insert (plist, elt.component)
      table.insert (list, plist)
   end

   table.insert (t, list)

   for elt in ncl:gmatch ('link') do
      local llist = {}

      for bind in elt:gmatch ('bind') do
         local blist = {}

         for k, v in ipairs (transition[bind.role]) do
            blist[k] = v
         end

         table.insert (blist, bind.component)
         table.insert (llist, blist)
      end

      table.insert (t, llist)
   end

   return t
end

return filter
