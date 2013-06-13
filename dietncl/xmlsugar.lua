-- xmlsugar.lua -- LuaXML sugar.
-- Copyright (C) 2013 PUC-Rio/Laboratorio TeleMidia
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

xml = require ('LuaXml')
TAG = xml.TAG
xml.PARENT = -1

-- Returns E if E is a LuaXML node, otherwise returns nil.
local function isxml (e)
   local t = getmetatable (e)
   if t and t.__index == xml then
      return e
   else
      return nil
   end
end

-- Returns E if E is an element without parent, otherwise returns nil.
local function isxmlroot (e)
   assert (isxml (e))
   if e[xml.PARENT] == nil then
      return e
   else
      return nil
   end
end

local function checkxml (e) return assert (isxml (e)) end
local function checkxmlroot (e) return assert (isxmlroot (e)) end

-- Sets PARENT to be the parent element of E.
local function setparent (e, parent)
   e[xml.PARENT] = parent
end

-- Adds sugar to the LibXML tree rooted at E.
local function sugarize (e)
   for i=1,#e do
      setparent (e[i], e)
      sugarize (e[i])
   end
   return e
end


-- Exported functions.

-- Sugarize xml.eval().
local _eval = xml.eval
function xml.eval (s)
   local status, e = pcall (_eval, s)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

-- Sugarize xml.load().
local _load = xml.load
function xml.load (s)
   local status, e = pcall (_load, s)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

-- Returns the parent of E.
function xml.parent(e)
   checkxml (e)
   return e[xml.PARENT]
end

-- Inserts element CHILD at position POS in child list of E.
-- If POS is nil, assume #E+1.
function xml.insert (e, pos, child)
   checkxml (e)
   if child == nil then
      child = pos
      pos = #e+1
   end
   if pos < 1 or pos > #e+1 then
      return nil
   end
   checkxmlroot (child)
   setparent (child, e)
   table.insert (e, pos, child)
   return pos
end

-- Fix xml.append ().
function xml.append (e, child)
   return xml.insert (e, child)
end

-- Removes and returns the element at position POS in child list of E.
function xml.remove (e, pos)
   checkxml (e)
   local child = table.remove (e, pos)
   setparent (child, nil)
   return child
end

-- Returns an iterator function that, each time it is called, returns the
-- next element in the child list of E.
function xml.children (e)
   checkxml (e)
   local i=1
   return function ()
      if i <= #e then
         local child = e[i]
         i = i + 1
         return child
      end
      return nil
   end
end

-- Returns an iterator function that, each time it is called, returns the
-- next attribute-value pair in the attribute table of E.
function xml.attributes (e)
   checkxml (e)
   local i = nil
   return function ()
      local k, v = next (e, i)
      while type (k) == 'number' do
         k, v = next (e, k)
      end
      i = k
      return k, v
   end
end

-- Returns an identical copy of the tree rooted at E.
function xml.clone (e)
   checkxml (e)
   local t = xml.new (e:tag ())
   for k,v in e:attributes () do
      t[k] = v
   end
   for i=1,#e do
      t[i] = (e[i]:clone ())
   end
   return t
end

-- Walk the elements of tree E.
-- ACTION is the function to be called at each element.
function xml.walk (e, action)
   checkxml (e)
   action (e)
   for i=1,#e do
      xml.walk (e[i], action)
   end
end

-- Returns an array containing the elements of tree E
-- that match a given <tag,attribute,value> triple.
-- TAG is a tag name or nil (any).
-- ATTRIBUTE is an attribute name or nil (any).
-- VALUE is a value string or nil (any).
function xml.match (e, tag, attribute, value)
   local t = {}
   local match = function (e)
      if (tag == nil or e:tag () == tag)
         and (attribute == nil or e[attribute] ~= nil)
         and (value == nil or e[attribute] == value) then
         t[#t+1] = e
      end
   end
   xml.walk (e, match)
   return t
end
