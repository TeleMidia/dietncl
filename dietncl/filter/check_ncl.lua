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

--
local function sequence (ncl, ttable, arg)
   if op ~= nil then
      operator[op] ()
   end

   for k, v in ipairs (ncl) do
      if v[0].tag == ttable[k] then
         filter.apply (ncl[k])
      else
         print ('wrong child')
      end
   end
end

--
local function pipe ()

end

--
local function one_or_more ()

end

--
local function zero_or_more ()

end

--
local function zero_or_one ()

end

--
local function exactly_one ()

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

   -- to do
   -- local list_child = syntax[arg].children

   -- for k in ipairs (ncl) do
   --    for i=1, #list_child do
   --       if ncl[k][0].tag == list_child[i] then
   --          filter.apply (ncl[k])
   --          index = i
   --          break
   --       end
   --    end

   --    if ncl[k][0].tag ~= list_child[index] then -- test children
   --       print ('wrong children')
   --       return nil
   --    end
   -- end

   while syntax[arg].children.op != nil do
      for k, v in pairs (operator) do
         if k == syntax[arg].children.op then
            v ()
            break
         end
      end
   end

   return ncl

end

return filter
