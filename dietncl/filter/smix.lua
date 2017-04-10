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
-- set has two more parameters, the media, its property and its value, that can also be a function

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


-- table to assess the type of test that needs to be made within the function
-- created from assessmentStatement
local comparator = {
   ['eq'] = function (x, y) return x == y end,
   ['ne'] = function (x, y) return x ~= y end,
   ['gt'] = function (x, y) return x > y end,
   ['lt'] = function (x, y) return x < y end,
   ['gte'] = function (x, y) return x >= y end,
   ['lte'] = function (x, y) return x <= y end
}

-- function to test compoundStatement operators (and, or)
local function test_compoundStatement (elt, childfunc)

   if elt.operator == 'and' then
      return function (m)
         for f in ipairs (childfunc) do
            if not f (m) then
               if elt.isNegated == 'true' then
                  return true
               else
                  return false
               end
            end
         end

         if elt.isNegated == 'true' then
            return false
         end

         return true
      end
   else -- elt.operator == 'or'
      return function (m)
         for f in ipairs (childfunc) do
            if f (m) then
               if elt.isNegated == 'true' then
                  return false
               else
                  return true
               end
            end

            if elt.isNegated == 'true' then
               return true
            end

            return false
         end
      end
   end
end

-- this filter needs to also get as a parameter the transition, because for
-- the set and seek actions, the function returned is different

-- remember to delete the transition parameter, this part is not to be done
-- in this function, but rather in the filter.apply

-- recursive function that returns the function from assessment statement
function filter.convert_statement (elt, ncl)

   if elt:tag () == 'assessmentStatement' then
      local var = nil
      local bind = {}
      local f = comparator[elt.comparator]

      for v in elt:gmatch ('attributeAssessment') do
         bind [#bind + 1] = ncl:match ('bind', 'role', v.role)
      end

      local media = {bind[1].component}
      local interface = {bind[1].interface}
      local value = elt:match ('valueAssessment')

      if value then
         return function (m)
            return f (m[media[1]][interface[1]], value.value)
         end
      end

      media[2] = bind[2].component
      interface[2] = bind[2].interface

      return function (m)
         return f (m[media[1]][interface[1]], m[media[2]][interface[2]])
      end
   end

   -- compoundStatement
   local childfunc = {}

   for child in elt:children () do
      childfunc [#childfunc + 1] = filter.convert_statement (child, ncl)
   end

   test_compoundStatement (elt, childfunc)
end


-- filter that creates the table representing the conversion of a ncl
-- program to smix
function filter.apply (ncl)
   local t = {}

   -- initialize media table with lambda, the whole application
   local medials = {lambda = {state = {},
                   prop = {abort = {},
                          resume = {}},
                   time = {}}}

   -- add medias to the table
   for elt in ncl:gmatch ('media') do
      medials [elt.id] = {state = {},
                          prop = {uri = elt.src},
                          time = {}}

      local prop = elt:match ('property')
      if prop then
         medials [elt.id] = {prop = {[prop.name] = prop.value}}
      end
   end

   table.insert (t, medials)

   -- initialize port table
   local list = {{'start', 'lambda'}}
   for elt in ncl:gmatch ('port') do
      local plist = {true, 'start', elt.component}
      table.insert (list, plist)
   end

   table.insert (t, list)

   -- initialize link table
   for link in ncl:gmatch ('link') do
      local llist = {}

      local conn = ncl:match ('causalConnector', 'id', link.xconnector)
      if conn == nil then
         return error
      end

      local statement = conn:match ('compoundStatement')
      if statement == nil then
         statement = conn:match ('assessmentStatement')
      end

      local cond = conn:match ('simpleCondition')
      local act = conn:match ('simpleAction')

      -- Add transition table to llist
      local bind = ncl:match ('bind', 'role', cond.role)

      if cond.transition == 'set' then
         -- this set is not gonna be in cond.transition, look again at this
         -- line in order to check its position and properly write this
         local blist = {cond.transition:sub (1, -2), bind.component, input}
      else
         local blist = {cond.transition:sub (1, -2), bind.component}
      end

      table.insert (llist, blist)

      -- Add action table to llist
      for bind in link:gmatch ('bind', 'role', act.role) do
         local f = comparator ['eq']

         if cond.transition == 'resumes' then
            blist = {{state(x) == 'paused', ...(barra)...},
               {f (t[1].lambda.resume, 1), 'start', bind.component, 'pinned'},
               {f (t[1].lambda.resume, 1), 'set', 'lambda', 'prop',
                'resume', nil, 'pinned'}}

         elseif cond.transition == 'aborts' then
            blist = {{state(x) ~= 'stopped', ...(barra)...},
               {f (t[1].lambda.abort, 1), 'stop', bind.component, 'pinned'},
               {f (t[1].lambda.abort, 1), 'set', 'lambda', 'prop', 'abort',
                nil, 'pinned'}}

         elseif cond.transition == 'set' then
            table.remove (llist)
            blist = {{'set', bind.component, 'input'},
               -- need to define this input and its value correctly
               {f (t[1][bind.component][prop]['input'], 'value'),
                act.actionType, bind.component}}

         else
            blist = {filter.convert_statement (statement, ncl),
                     act.actionType, bind.component}
         end

         table.insert (llist, blist)
      end

      table.insert (t, llist)
   end

   return t
end

return filter
