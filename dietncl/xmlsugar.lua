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
TAG          = xml.TAG
xml.PARENT   = -1
xml.USERDATA = -2

-- Checks whether E is a LuaXML element and returns E.

local function checkxml (e)
   local t = getmetatable (e)
   assert (t and t.__index == xml)
   return e
end

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

-- Searches for a given child element of E.
-- CHILD is the searched element or its position in child list of E.
-- Returns both the searched element and its position.

local function findchild (e, child)
   local pos
   if type (child) == 'number' then
      pos = child
      child = assert (e[pos])
   else
      checkxml (child)
      assert (child[xml.PARENT] == e)
      for i=1,#e do
         if child == e[i] then
            pos = i
         end
      end
      assert (pos)
   end
   return child, pos
end


-- Exported functions.

-- Parses the XML string S.
-- Returns a new XML handle if successful,
-- otherwise returns nil plus error message.

local _eval = xml.eval
function xml.eval (s)
   local status, e = pcall (_eval, s)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

-- Parses the XML document at path name S.
-- Returns a new XML handle if successful,
-- otherwise returns nil plus error message.

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
      pos = #e + 1
   end
   if pos < 1 or pos > #e+1 then
      return nil
   end
   assert (child[xml.PARENT] == nil)
   setparent (child, e)
   table.insert (e, pos, child)
   return pos
end

-- Replacement for the original xml.append() function.

function xml.append (e, child)
   return xml.insert (e, child)
end

-- Removes an element from child list of E.
-- CHILD is the element to be removed or its position in child list of E
-- Returns the removed element and its position in child list of E.

function xml.remove (e, child)
   checkxml (e)
   local child, pos = findchild (e, child)
   table.remove (e, pos)
   setparent (child, nil)
   return child, pos
end

-- Replaces an element in child list of E.
-- OLD is the element to be replaced or its position in child list of E.
-- NEW is the replacement element.
-- Returns the replaced element and its position in child of E.

function xml.replace (e, old, new)
   checkxml (e)
   checkxml (new)
   assert (new[xml.PARENT] == nil)
   local old, pos = findchild (e, old)
   e[pos] = new
   setparent (new, e)
   setparent (old, nil)
   return old, pos
end

-- Returns user data previously attached to element E.
-- KEY is the key the user data was attached to.

function xml.getuserdata (e, key)
   checkxml (e)
   if e[xml.USERDATA] == nil then
      return nil
   end
   return e[xml.USERDATA][key]
end

-- Attaches user data to element E.
-- KEY is the key to attach the user data to.
-- USERDATA is a user data to attach to the element.

function xml.setuserdata (e, key, userdata)
   checkxml (e)
   if e[xml.USERDATA] == nil then
      e[xml.USERDATA] = {}
   end
   e[xml.USERDATA][key] = userdata
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

-- Checks whether tree E1 is equal to tree E2.

local function equal_attributes (e1, e2)
   for k,_ in e1:attributes () do
      if e1[k] ~= e2[k] then
         return false
      end
   end
   return true
end

function xml.equal (e1, e2)
   checkxml (e1)
   checkxml (e2)
   if (e1:tag () ~= e2:tag ())
      or (not equal_attributes (e1, e2))
      or (not equal_attributes (e2, e1))
      or (#e1 ~= #e2) then
      return false
   end
   for i=1,#e1 do
      if (not e1[i]:equal (e2[i]))
         or (not e2[i]:equal (e1[i])) then
         return false
      end
   end
   return true
end

-- Returns an identical copy of tree E.

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

-- Walks across the elements of tree E.
-- ACTION is a function to be called at each element.

function xml.walk (e, action)
   checkxml (e)
   action (e)
   for i=1,#e do
      xml.walk (e[i], action)
   end
end

-- Looks for all elements that match the triple (tag,attribute,value) of
-- tree E and returns an array containing the matched elements.
-- TAG is a tag name or nil (any).
-- ATTRIBUTE is an attribute name or nil (any).
-- VALUE is a value string or nil (any).
--
-- REGEXP is an (optional) integer between 0-7 that determines whether TAG,
-- ATTR, and VALUE are to be interpret as regular expressions: if the third
-- bit of REGEXP is set, treat TAG as regexp; if its second bit is set,
-- treat ATTR as regexp; if its first bit is set, treat VALUE as regexp.

local function eq (s, pattern, regexp)
   if regexp then
      return s:match (pattern) ~= nil
   else
      return s == pattern
   end
end

local function domatch0 (e, tag, attr, value,
                         cmptag, cmpattr, cmpval, result)

   if tag and not cmptag (e:tag (), tag) then
      return                    -- fail
   end

   if not attr then
      cmpattr = function (...) return true end
   end

   if not value then
      cmpval = function (...) return true end
   end

   local list = {}
   for k,_ in e:attributes () do
      if cmpattr (k, attr) then
         list[#list+1] = k
      end
   end

   if attr and #list == 0 then
      return                    -- fail
   end

   if value then
      for _,attr in ipairs (list) do
         assert (e[attr])
         if cmpval (e[attr], value) then
            goto success
         end
      end
      return                    -- fail
   end

   ::success::
   table.insert (result, e)
end

local function domatch (e, tag, attr, value, regexp)
   local result = {}            -- list of matches
   local match = function (e)
      local re = regexp or 0
      local bit = bit32.extract
      domatch0 (e, tag, attr, value,
                function (x,y) return eq (x, y, bit (re, 2) ~= 0) end,
                function (x,y) return eq (x, y, bit (re, 1) ~= 0) end,
                function (x,y) return eq (x, y, bit (re, 0) ~= 0) end,
                result)
   end
   xml.walk (e, match)
   return result
end

function xml.match (...)
   return table.unpack (domatch (...))
end

-- Returns an iterator function that, each time is called, returns the next
-- element of tree E that matches the triple (tag,attribute,value).
-- TAG is a tag name or nil (any).
-- ATTRIBUTE is an attribute name or nil (any).
-- VALUE is a value string or nil (any).

function xml.gmatch (...)
   local t = domatch (...)
   local i = 1
   return function ()
      if i <= #t then
         local x = t[i]
         i = i + 1
         return x
      end
      return nil
   end
end
