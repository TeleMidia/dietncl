-- prenorm.lua -- Simplifies links and connectors.
-- Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
--
-- This file is part of DietNCL.
--
-- DietNCL is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DietNCL is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DietNCL.  If not, see <http://www.gnu.org/licenses/>.


                          -- The PRENORM Filter --

-- The "prenorm" filter simplifies the links and connectors from a given NCL
-- document.  More specifically, it makes sure that the document satisfies
-- the following five restrictions.
--
--  (1) Each connector is referenced by exactly one link.
--
--  (2) All connectors and links contain no link, bind, or connector
--      parameters, i.e., no <linkParam>, <bindParam>, or <connectorParam>
--      elements -- except if the infamous "pega dali" is used.
--
--  (3) The compound conditions and compound actions of all connectors have
--      no "delay" attribute.
--
--  (4) The simple conditions and simple actions of all connectors are
--      referenced by exactly one bind in the associated links.
--
--  (5) The compound actions and compound statements of all connectors are
--      binary and its compound conditions are either binary or ternary, and
--      have exactly one child (assessment or compound) statement.
--
-- This filter depends on the "import" filter, i.e., it assumes that the
-- given document has no import declaration.

require ('dietncl.xmlsugar')
local xml    = xml
local aux    = require ('dietncl.nclaux')

local assert = assert
local ipairs = ipairs

local print  = print

module (...)

-- Makes sure that each connector is referenced by exactly one link.
-- Returns the updated document.

local function make_bijection (ncl)
   for conn in ncl:gmatch ('causalConnector') do
      local list = {ncl:match ('link', 'xconnector', conn.id)}

      if #list == 0 then
         xml.remove (conn:parent (), conn)
         goto continue
      end

      if #list == 1 then
         goto continue          -- nothing to do
      end

      for i=1,#list-1 do
         local parent = conn:parent ()
         local dup = conn:clone ()

         dup.id = aux.gen_id (ncl)
         list[i].xconnector = dup.id
         parent:insert (dup)
      end

      ::continue::
   end
   return ncl
end

-- Removes all parameters from links and connectors.
-- This function assumes that NCL satisfies restriction (1).

local function remove_params (ncl)
   for conn in ncl:gmatch ('causalConnector') do

      local dont_delete = {} -- connector parameters that we can't delete
      local link             -- link associated with connector conn

      link = ncl:match ('link', 'xconnector', conn.id)

      for bind in link:gmatch ('bind') do

         local bindref = conn:match (nil, 'role', bind.role)
         if bindref == nil then
            goto continue       -- nothing to do ("pega dali")
         end

         for k,v in bindref:attributes () do

            if v:sub(1,1) ~= '$' then
               goto continue    -- nothing to do
            end

            local name = v:sub (2)
            local connparam = conn:match ('connectorParam', 'name', name)
            if connparam == nil then
               goto continue    -- nothing to do
            end

            -- Get the associated bind-parameter.

            local bindparam
            if #bind == 0 then
               local p = link:match ('linkParam', 'name', name)
               if p == nil then
                  goto continue -- nothing to do
               end
               bindparam = xml.new ('bindParam')
               bindparam.name = p.name
               bindparam.value = p.value
               bind:insert (bindparam)
            else
               bindparam = bind[1]
            end

            -- If is an infamous "pega-dali", then don't delete.

            if bindparam.value:sub (1,1) == '$' then
               dont_delete[connparam] = true
               goto continue
            end

            -- Replace bind's value for connector's value and remove the
            -- bind-parameter.

            bindref[k] = bindparam.value
            bind:remove (bindparam)

            ::continue::
         end

         ::continue::
      end

      -- Remove the connector parameters from conn that are not used by some
      -- infamous "pega-dali".

      for p in conn:gmatch ('connectorParam') do
         if dont_delete[p] then
            goto continue       -- do nothing
         end
         conn:remove (p)
         ::continue::
      end

      -- Remove all link-parameters from link.

      for p in link:gmatch ('linkParam') do
         link:remove (p)
      end
   end

   return ncl
end

-- Removes the "delay" attribute from compound conditions and actions.
-- This function assumes that NCL satisfies restriction (2).

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
      delay = delay + (aux.timetoseconds (x.delay or '0s'))
      x.delay = nil
   end
   for i=1,#x do
      remove_compound_delay_tail (x[i], delay)
   end
end

local function remove_compound_delay (ncl)
   for conn in ncl:gmatch ('causalConnector') do
      for x in conn:children () do
         remove_compound_delay_tail (x, 0)
      end
   end
   return ncl
end

-- This auxiliary function duplicates a simple condition or a simple action.

local function duplicator (bind, conn, ...)
    for x in conn:gmatch(...) do
               if x.role==bind.role then
                  local duplicate = x:clone ()
                  local parent = x:parent ()
                  local x, pos =  parent:findchild (x)
                  parent:insert (pos + 1, duplicate)
               end
	end
end

-- Make sure that simple conditions and simple actions of all connectors are referenced by exactly one bind in the associated links.
-- Restriction (4).

local function make_condition_action_bijection (ncl)
   for link in ncl:gmatch('link') do
      
      local conn = ncl:match ('causalConnector', 'id', link.xconnector)
      local roleTable={}
      
      for bind in link:gmatch('bind') do
         if not roleTable[bind.role] then
            roleTable[bind.role]=0
         else
            roleTable[bind.role]=roleTable[bind.role]+1
            duplicator(bind, conn, 'simpleCondition')
	    duplicator(bind, conn, 'simpleAction')
         end
      
      end
      print(conn, link)
   end
end


-- Exported functions.

function apply (ncl)
   make_bijection (ncl)
   remove_params (ncl)
   remove_compound_delay (ncl)
   make_condition_action_bijection (ncl)
   return ncl
end
