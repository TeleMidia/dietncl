--[[ dietncl.xmlsugar -- LuaXML sugar.
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

local assert = assert
local bit = bit32.extract
local getmetatable = getmetatable
local ipairs = ipairs
local next = next
local pcall = pcall
local table = table
local type = type

-- Workaround bugs in LuaXML eval() and tag().
local xml = require'LuaXML'
_G.xml = xml
_G.TAG = xml.TAG
_ENV = nil

---
-- Parsing, representation, and manipulation of XML trees.
-- @classmod dietncl.xmlsugar
---
do
   xml.PARENT = -1
   xml.USERDATA = -2
   xml._eval = xml.eval
   xml._load = xml.load
end

-- Checks whether E is a LuaXML element.
local function checkxml (e)
   local t = getmetatable (e)
   assert (t and t.__index == xml)
   return e
end

-- Sets PARENT to be the parent element of E.
local function setparent (e, parent)
   e[xml.PARENT] = parent
end

-- Adds sugar to the tree rooted at E.
local function sugarize (e)
   for i=1,#e do
      setparent (e[i], e)
      sugarize (e[i])
   end
   return e
end


--- Methods
-- @section Methods
---

---
-- Parses XML string.
-- @param s XML string.
-- @return[1] XML tree (root element), if successful.
-- @return[2] `nil` plus error message, otherwise.
---
function xml:eval (s)
   local s = s or self
   local status, e = pcall (xml._eval, s)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

---
-- Parses XML file.
-- @string path path to XML file.
-- @return[1] XML tree (root element), if successful.
-- @return[2] `nil` plus error message, otherwise.
---
function xml:load (path)
   local path = path or self
   local status, e = pcall (xml._load, path)
   if status == false or e == nil then
      return nil, e
   end
   return sugarize (e)
end

---
-- Gets element's parent.
-- @return parent element.
---
function xml:parent()
   checkxml (self)
   return self[xml.PARENT]
end

---
-- Searches for element's child.  This function assumes that *child* is in
-- element's child list.
-- @param child the searched child or its position in child list.
-- @return *child* and its position in child list.
---
function xml:findchild (child)
   local pos
   if type (child) == 'number' then
      pos = child
      child = assert (self[pos])
   else
      checkxml (child)
      assert (child[xml.PARENT] == self)
      for i=1,#self do
         if child == self[i] then
            pos = i
         end
      end
      assert (pos)
   end
   return child, pos
end

---
-- Inserts child element.
-- @param[opt] pos position in child list or `nil` (last+1).
-- @param child child to be inserted.
-- @return the position where *child* was inserted.
---
function xml:insert (pos, child)
   checkxml (self)
   if child == nil then
      child = pos
      pos = #self + 1
   end
   assert (pos >= 1 and pos <= #self + 1)
   assert (child[xml.PARENT] == nil)
   setparent (child, self)
   table.insert (self, pos, child)
   return pos
end

---
-- Removes child element.
-- @param child child to be removed or its position in child list.
-- @return *child* and its position in child list.
---
function xml:remove (child)
   checkxml (self)
   local child, pos = self:findchild (child)
   table.remove (self, pos)
   setparent (child, nil)
   return child, pos
end

---
-- Replaces child element.
-- @param old child to be replaced or its position in child list.
-- @param new the replacement element.
-- @return *old* and its position in child list.
---
function xml:replace (old, new)
   checkxml (self)
   checkxml (new)
   assert (new[xml.PARENT] == nil)
   local old, pos = self:findchild (old)
   self[pos] = new
   setparent (new, self)
   setparent (old, nil)
   return old, pos
end

---
-- Gets element user data.
-- @param key key the data was attached to.
-- @return the data with the given key if any.
---
function xml:getuserdata (key)
   checkxml (self)
   if self[xml.USERDATA] == nil then
      return nil
   end
   return self[xml.USERDATA][key]
end

---
-- Sets element user data.
-- @param key key to attach the data to.
-- @param data data to attach to the element.
---
function xml:setuserdata (key, data)
   checkxml (self)
   if self[xml.USERDATA] == nil then
      self[xml.USERDATA] = {}
   end
   self[xml.USERDATA][key] = data
end

---
-- Gets child list iterator.
-- @return iterator function for element's child list.
---
function xml:children ()
   checkxml (self)
   local t = {}
   for i=1,#self do
      t[i] = self[i]
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
-- Gets attribute table iterator.
-- @return iterator function for element's attribute table.
---
function xml:attributes ()
   checkxml (self)
   local i = nil
   return function ()
      local k, v = next (self, i)
      while type (k) == 'number' do
         k, v = next (self, k)
      end
      i = k
      return k, v
   end
end

---
-- Tests whether the element tree is equal to another tree.
-- @function xml:equal
-- @param other XML tree (root element).
-- @return[1] `true`, if successful.
-- @return[2] `false`, otherwise.
---
local function equal_attributes (e1, e2)
   for k,_ in e1:attributes () do
      if e1[k] ~= e2[k] then
         return false
      end
   end
   return true
end

function xml:equal (other)
   checkxml (self)
   checkxml (other)
   if (self:tag () ~= other:tag ())
      or (not equal_attributes (self, other))
      or (not equal_attributes (other, self))
      or (#self ~= #other) then
      return false
   end
   for i=1,#self do
      if (not self[i]:equal (other[i]))
         or (not other[i]:equal (self[i])) then
         return false
      end
   end
   return true
end

---
-- Clones element tree.
-- @return a copy of element tree (root element).
---
function xml:clone ()
   checkxml (self)
   local t = xml.new (self:tag ())
   for k,v in self:attributes () do
      t[k] = v
   end
   for i=1,#self do
      t[i] = (self[i]:clone ())
      setparent (t[i], t)
   end
   return t
end

---
-- Traverses element tree.
-- @param action a function to be applied to each traversed element.
---
function xml:walk (action)
   checkxml (self)
   action (self)
   for i=1,#self do
      self[i]:walk (action)
   end
end

---
-- Searches for all elements that match the given search criterion in the
-- element's tree.
-- @function xml:match
-- @param[opt] tag tag name or `nil` (any).
-- @param[opt] attr attribute name or `nil` (any).
-- @param[opt] value attribute value or `nil` (any).
-- @param[opt=0] regexp integer between 0-7 that determines whether *tag*,
-- *attr*, or *value* are to be interpreted as regular expressions: if the
-- third bit of *regexp* is set, treat *tag* as regexp; if its second bit is
-- set, treat *attr* as regexp; if its first bit is set, treat *value* as
-- regexp.
-- @return the matched elements.
---
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

function xml:match (...)
  return table.unpack (domatch (self, ...))
end

---
-- Gets match iterator.
-- @param[opt] tag tag name or `nil` (any).
-- @param[opt] attr attribute name or `nil` (any).
-- @param[opt] value a value string or `nil` (any).
-- @param[opt=0] regexp see `xml:match`.
-- @return an iterator function for the given search criterion.
---
function xml:gmatch (...)
   local t = domatch (self, ...)
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
