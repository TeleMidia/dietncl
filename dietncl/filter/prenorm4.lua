--[[ prenorm4.lua -- Fourth pre-normalization step.
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

-- The PRENORM1-5 filters simplify links and connectors from a given NCL
-- document.  This filter, PRENORM4, implements the fourth pre-normalization
-- step: It guarantees that the simple conditions and simple actions of all
-- connectors are referenced by exacbly one bind in the associated links.
--
-- Depends: PRENORM1.

local filter = {}

local assert = assert
local pairs = pairs

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

local alias_map = {
-- ALIAS                  EVENT_TYPE      TRANSITION
   onAbort             = {'presentation', 'aborts'},
   onAbortAttribution  = {'attribution',  'aborts'},
   onAbortSelection    = {'selection',    'aborts'},
   onBeginAttribution  = {'attribution',  'starts'},
   onBeginSelection    = {'selection',    'starts'},
   onEnd               = {'presentation', 'stops'},
   onEndAttribution    = {'attribution',  'stops'},
   onEndSelection      = {'selection',    'stops'},
   onPause             = {'presentation', 'pauses'},
   onPauseAttribution  = {'attribution',  'pauses'},
   onPauseSelection    = {'selection',    'pauses'},
   onResume            = {'presentation', 'resumes'},
   onResumeAttribution = {'attribution',  'resumes'},
   onResumeSelection   = {'selection',    'resumes'},
   onSelection         = {'selection',    'starts'},
   onBegin             = {'presentation', 'starts'},
   abort               = {'presentation'},
   pause               = {'presentation'},
   resume              = {'presentation'},
   set                 = {'attribution'},
   start               = {'presentation'},
   stop                = {'presentation'},
}
do
   for alias,t in pairs (alias_map) do
      t[2] = alias
   end
end

function filter.apply (ncl)
   for link in ncl:gmatch ('link') do
      local conn = ncl:match ('causalConnector', 'id', link.xconnector)
      -- Expand aliases.
      for x in conn:gmatch ('^simple[AC].*$', nil, nil, 4) do
         if alias_map[x.role] then
            x.eventType = alias_map[x.role][1]
            if x.role:match ('^on.*') then
               x.transition = alias_map[x.role][2]
            else
               x.actionType = alias_map[x.role][2]
            end
         end
      end

      -- Copy the <simpleAction> (or <simpleCondition>) elements that are
      -- referenced by more than one <bind> element; wrap the original
      -- element and the copies into a compound action (or condition); and
      -- update the associated binds.
      do
         local count = {}
         for bind in link:gmatch ('bind') do
            local r = bind.role
            count[r] = (count[r] or 0) + 1
            if count[r] <= 1 then
               goto continue    -- nothing to do
            end
            local x = assert (conn:match (nil, 'role', bind.role))
            if count[r] == 2 then -- make compound
               local comp
               if x:tag () == 'simpleAction' then
                  comp = xml.new ('compoundAction')
                  comp.operator = x.qualifier or 'par'
               else
                  comp = xml.new ('compoundCondition')
                  comp.operator = x.qualifier or 'and'
               end
               x = xml.replace (x:parent (), x, comp)
               comp:insert (x)
            end
            local copy = x:clone ()
            copy.role = aux.gen_id (ncl)
            bind.role = copy.role
            local parent = x:parent ()
            local x, pos =  parent:findchild (x)
            parent:insert (pos + count[r] - 1, copy)
            ::continue::
         end
      end
   end
   return ncl
end

return filter
