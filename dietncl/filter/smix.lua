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
      local act = {}
      for elt in conn:gmatch ('simpleAction') do
         act [#act + 1] = elt
      end

      -- Add transition table to llist
      --- check if there are role clashes inside of a link
      local bind = link:match ('bind', 'role', cond.role)

      local blist = {}
      if cond.eventType == 'attribution' then
         local input = link:match ('bind', 'role', cond.role)
         --- this is the set event, change the below line
         --- is there onSet role for simpleCondition?
         blist = {'set', bind.component, input.interface}
      else
         blist = {cond.transition:sub (1, -2), bind.component}
      end

      table.insert (llist, blist)

      -- Add action table to llist
      for i = 1, #act do
         local bind = link:match ('bind', 'role', act[i].role)
         local f = comparator ['eq']
         local m1 = bind.component

         --- check the last table, what is r_r, a_a?
         --- the line where they are was supposed to be the one that
         --- triggers the condition onResume / onAbort, meaning that
         --- its not a flag that needs to be set, and the action is not
         --- supposed to be pinned
         if act[i].actionType == 'resume' then
            blist = {{true, 'set', 'lambda', 'u', -1},
               {function (m) return m[m1][state] == 'paused' end,
                  'set', 'lambda', 'u', 1},
               {'iter', function (m) return m[lambda].u end,
                {true, 'set', m1, 'r_f', 1, 'pinned'}},
               {'iter', function (m) return -1 * m[lambda].u end,
                {true, 'set', m1, 'r_f', 0, 'pinned'}},
               {function (m) return m[m1].r_f == 1 end,
                  'start', m1, nil, nil, 'pinned'},
               {function (m) return m[m1].r_f == 1 end,
                  'set', m1, 'r_r', nil}}

         elseif act[i].actionType == 'abort' then
            blist = {{true, 'set', 'lambda', 'u', -1},
               {function (m) return m[m1][state] ~= 'stopped' end,
                  'set', 'lambda', 'u', 1},
               {'iter', function (m) return m[lambda].u end,
                {true, 'set', m1, 'a_f', 1, 'pinned'}},
               {'iter', function (m) return -1 * m[lambda].u end,
                {true, 'set', m1, 'a_f', 0, 'pinned'}},
               {function (m) return m[m1].r_f == 1 end,
                  'stop', m1, nil, nil, 'pinned'},
               {function (m) return m[m1].r_f == 1 end,
                  'set', m1, 'a_a', nil}}

         elseif act[i].actionType == 'start' and
         act[i].eventType == 'attribution' then
            blist = {filter.convert_statement (statement, ncl), 'set', m1,
                     bind.interface, act[i].value}

         else
            blist = {filter.convert_statement (statement, ncl),
                     act[i].actionType, m1}
         end

         table.insert (llist, blist)
      end

      table.insert (t, llist)
   end

   return t
end

return filter
