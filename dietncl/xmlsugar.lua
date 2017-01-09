--[[ dietncl.xmlsugar -- LuaXML sugar.
     Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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

local xml = require ('LuaXml')

-- Workaround bugs in LuaXml eval() and tag().
_G.xml = xml
_G.TAG = xml.TAG

local assert = assert
local bit = bit32.extract
local getmetatable = getmetatable
local ipairs = ipairs
local next = next
local pcall = pcall
local table = table
local type = type
_ENV = nil

--- XML trees.
-- @module xml.

xml.PARENT = -1
xml.USERDATA = -2
xml._eval = xml.eval
xml._load = xml.load

---
-- Checks whether E is a LuaXML element.
-- @tab e metatable.
-- @return E.

local function checkxml (e)
   local t = getmetatable (e)
   assert (t and t.__index == xml)
   return e
end

---
-- Sets PARENT to be the parent element of E.
-- @param e LuaXML element
-- @param parent LuaXML element

local function setparent (e, parent)
   e[xml.PARENT] = parent
end

---
-- Adds sugar to the LibXML tree rooted at E.
-- @param e LuaXML element.
-- @return E.

local function sugarize (e)
   for i=1,#e do
      setparent (e[i], e)
      sugarize (e[i])
   end
   return e
end

---
-- Parses the XML string S.
-- @string s XML string.
-- @return new XML handle, if successful.
-- @return 'nil' plus error message, otherwise.

function xml.eval (s)
   local status, e = pcall (xml._eval, s)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

---
-- Parses the XML document.
-- @string s XML string.
-- @return new XML handle, if successful.
-- @return 'nil' plus error message, otherwise.

function xml.load (s)
   local status, e = pcall (xml._load, s)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

---
-- Searches for the parent of E.
-- @param e LuaXML element.
-- @return parent of E.

function xml.parent(e)
   checkxml (e)
   return e[xml.PARENT]
end

---
-- Searches for a given child element of E.
-- @param e LuaXML element.
-- @param child the searched element or its position in child list of E.
-- @return the searched element.
-- @return its position.

function xml.findchild (e, child)
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

---
-- Inserts element CHILD at position POS in child list of E.
-- If POS is nil, assume #E+1.
-- @param e LuaXML element.
-- @param pos position to be inserted.
-- @param child element to be inserted.
-- @return position.

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

---
-- Replacement for the original xml.append() function.
-- @param e LuaXML element.
-- @param child LuaXML element.
-- @return very own table.

function xml.append (e, child)
   return xml.insert (e, child)
end

---
-- Removes an element from child list of E.
-- @param e LuaXML element.
-- @param child element to be removed or its position.
-- @return the removed element.
-- @return the position of the element removed.

function xml.remove (e, child)
   checkxml (e)
   local child, pos = xml.findchild (e, child)
   table.remove (e, pos)
   setparent (child, nil)
   return child, pos
end

---
-- Replaces an element in child list of E.
-- @param e LuaXML element.
-- @param old the element to be replaced or its position.
-- @param new the replacement element.
-- @return the replaced element.
-- @return its position.

function xml.replace (e, old, new)
   checkxml (e)
   checkxml (new)
   assert (new[xml.PARENT] == nil)
   local old, pos = xml.findchild (e, old)
   e[pos] = new
   setparent (new, e)
   setparent (old, nil)
   return old, pos
end

---
-- Find user data previously attached to element E.
-- @param e LuaXML element.
-- @param key the key the user data was attached to.
-- @return user data previously attached to E.

function xml.getuserdata (e, key)
   checkxml (e)
   if e[xml.USERDATA] == nil then
      return nil
   end
   return e[xml.USERDATA][key]
end

---
-- Attaches user data to element E.
-- @param e LuaXML element.
-- @param key the key to attach the user data to.
-- @param userdata is a user data to attach to the element.

function xml.setuserdata (e, key, userdata)
   checkxml (e)
   if e[xml.USERDATA] == nil then
      e[xml.USERDATA] = {}
   end
   e[xml.USERDATA][key] = userdata
end

---
-- Returns an iterator function that, each time it is called, returns the
-- next element in the child list of E.
-- @param e LuaXML element.
-- @return iterator function.

function xml.children (e)
   checkxml (e)
   local t = {}
   for i=1,#e do
      t[i] = e[i]
   end
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

---
-- Returns an iterator function that, each time it is called, returns the
-- next attribute-value pair in the attribute table of E.
-- @param e LuaXML element.
-- @return iterator function.

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

---
-- Checks whether tree E1 is equal to tree E2.
-- @param e1 LuaXML element.
-- @param e2 LuaXML element.
-- @return boolean for element parity.

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

---
-- Create an identical copy of tree E.
-- @param e LuaXML element.
-- @return copy of E.

function xml.clone (e)
   checkxml (e)
   local t = xml.new (e:tag ())
   for k,v in e:attributes () do
      t[k] = v
   end
   for i=1,#e do
      t[i] = (e[i]:clone ())
      setparent (t[i], t)
   end
   return t
end

---
-- Walks across the elements of tree E.
-- @param e LuaXML element.
-- @param action a function to be called at each element.

function xml.walk (e, action)
   checkxml (e)
   action (e)
   for i=1,#e do
      xml.walk (e[i], action)
   end
end

---
-- Looks for all elements that match the triple (tag,attribute,value) of
-- tree E and returns the matched elements.
-- @function xml.match
-- @param e LuaXML element.
-- @param tag  a tag name or nil (any).
-- @param attr an attribute name or nil (any).
-- @param value a value string or nil (any).
-- @param regexp an (optional) integer between 0-7 that determines whether TAG,
-- ATTR, and VALUE are to be interpret as regular expressions: if the third
-- bit of REGEXP is set, treat TAG as regexp; if its second bit is set,
-- treat ATTR as regexp; if its first bit is set, treat VALUE as regexp.
-- @return the matched elements.

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

---
-- Create an iterator function that, each time is called, returns the next
-- element of tree E that matches the triple (tag,attribute,value).
-- @param tag a tag name or nil (any).
-- @param attr an attribute name or nil (any).
-- @param value a value string or nil (any).
-- @return an iterator function.

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

return xml
