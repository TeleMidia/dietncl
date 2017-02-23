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
local ipairs = ipairs
local pairs = pairs
local table = table
local type = type
local filter = {}
local xml = require ('dietncl.xmlsugar')
local syntax = require ('NCLtable')
_ENV = nil

---
-- Check NCL document to test if it complies with the NCL handbook.
--
-- @module dietncl.filter.check_ncl
---

---
-- Local functions
--

-- makes children list from the table with the outer [op] before calling
-- the operation function
local function test_child ()

end

--
local function sequence (ncl, children) -- children is a list
   local index = 1

   for _, v in ipairs (children) do
      if v == ncl[index][0].tag then
         index = index + 1
      end
   end

   if ncl[index] then
      print ('wrong child (sequence)')
      return nil
   end

   return children
end

--
local function pipe (ncl, children)
   for _, v in ipairs (ncl) do
      local index = 1

      for i=1, #children do
         if v[0].tag == children[i] then
            index = i
            break
         end
      end

      if v[0].tag ~= children[index] then
         print ('wrong child (pipe)')
         return nil
      end
   end
end

--
local function one_or_more (ncl, children)
   local index

   for _, c in ipairs (children) do
      for k, v in ipairs (ncl) do
         if v[0].tag == c then
            index = k
            break
         end
      end

      if ncl[index][0].tag ~= c then
         print ('wrong child (one_or_more)')
         return nil
   end
end

--
local function zero_or_more ()
   local index

   for _, v in ipairs (ncl) do
      for i=1, #children do
         if children[i] == v[0].tag then
            index = i
            break
         end
      end

      if children[index] ~= v[0].tag then
         print ('wrong child (zero_or_more)')
         return nil
      end
   end
end

--
local function zero_or_one ()
   local count = 0

   for i=1, #children do
      for _, v in ipairs (ncl) do
         if children[i] == v[0].tag then
            count = count + 1
         end
      end

      if count > 1 then
         print ('wrong child (exactly_one)')
         return nil
      end
   end
end

--
local function exactly_one (ncl, children)
   local count = 0

   for i=1, #children do
      for _, v in ipairs (ncl) do
         if children[i] == v[0].tag then
            count = count + 1
         end
      end

      if count ~= 1 then
         print ('wrong child (exactly_one)')
         return nil
      end
   end
end

-- Table to define what operation needs to be followed
local operator = {
   [','] = sequence ()

   ['|'] = pipe ()

   ['+'] = one_or_more ()

   ['*'] = zero_or_more ()

   ['?'] = zero_or_one ()

   ['!'] = exactly_one ()
}

---
-- The CHECK NCL filter checks if the file is a valid NCL document or not.
-- @param ncl NCL Document.
-- @return NCL document or an error message.
---
function filter.apply (ncl)

   local index
   local arg = ncl[0].tag

   -- test tag
   if type (syntax[arg]) ~= 'table' then
      print ('wrong tag')
      return nil
   end

   if syntax[arg].parent then
      for k, v in ipairs (syntax[arg].parent) do
         if v == ncl[0].parent[0].tag then
            index = k
            break
         end
      end

      -- test parent
      if syntax[arg].parent[index] ~= ncl[0].parent[0].tag then
         print ('wrong parent')
         return nil
      end
   end

   local ncl_opt = {}

   -- build optional attributes table
   for k in pairs (ncl) do
      if type (k) == 'string' then
         ncl_opt[#ncl_opt + 1] = k
      end
   end

   local list_req = {}
   local list_opt = {}

   if syntax[arg].required_attrs then
      for k, v in pairs (syntax[arg].required_attrs) do
         list_req[k] = v
      end
   end

   if syntax[arg].optional_attrs then
      for k, v in pairs (syntax[arg].optional_attrs) do
         list_opt[k] = v
      end
   end

   -- test required attributes
   for i=1, #list_req do
      if ncl[list_req[i]] == nil then
         print ('wrong required attrs')
         return nil
      else -- delete required attributes from ncl optionals list
         for j=1, #ncl_opt do
            if ncl_opt[j] == list_req[i] then
               table.remove (ncl_opt, j)
            end
         end
      end
   end

   for i=1, #ncl_opt do
      for j=1, #list_opt do
         if ncl_opt[i] == list_opt[j] then
            index = j
            break
         end
      end

      -- test optional attributes
      if ncl_opt[i] ~= list_opt[index] then
         print ('wrong optional attrs')
         return nil
      end
   end

   if ncl[1] ~= nil then
      -- test children
      local child_list = {}
      test_child (ncl, child_list)

      -- call filter recursively for each children
      for k in ipairs (ncl) do
         filter.apply (ncl[k])
      end
   end

   return ncl

end

return filter
