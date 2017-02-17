--[[ filter.unused_media -- Remove unused medias.
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
local filter = {}
local xml = require ('dietncl.xmlsugar')
_ENV = nil

---
-- Check NCL document to test if it complies with the NCL handbook.
--
-- @module dietncl.filter.check_ncl
---

-- Add '?, *' elements after first couple of tests

local syntax = {
   ncl = {
      parent = nil,
      required_attrs = {'id'},
      optional_attrs = {'title', 'xmlns'},
      children = {'head', 'body'}
   },
   head = {
      parent = {'ncl'},
      required_attrs = nil,
      optional_attrs = nil,
      children = {'importedDocumentBase', 'ruleBase', 'transitionBase',
                  'regionBase', 'descriptorBase', 'connectorBase',
                  'meta', 'metadata'}
   },
   body = {
      parent = {'ncl'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'port', 'property', 'media', 'context', 'switch',
                  'link', 'meta', 'metadata'}
   }
}

local function test_end_table ()
end

---
-- The CHECK NCL filter makes sure that the file is a valid NCL
-- document.
-- @param ncl Lua table with NCL Document.
-- @return TRUE or an error message.
---
function filter.apply (ncl)

   -- remember to change table acces from syntax.arg.parent to
   -- syntax.arg.parent[1] (first one returns a table, not a string)

   local arg = ncl[0].tag

   if !syntax.arg then -- test tag
      print ('wrong tag')
      return nil
   elseif syntax.arg.parent ~= ncl[0].parent then -- test parent
      print ('wrong parent')
      return nil
   end


   local ncl_opt = {}

   for k in pairs (ncl) do -- build optional attributes table
      if k == string then
         ncl_opt[#ncl_opt + 1] = k
      end
   end

   local list_req = {syntax.arg.required_attrs}
   local list_opt = {syntax.arg.optional_attrs}

   for i=1, #list_req do -- test required attributes
      if !ncl.list_req[i] then
         print ('wrong required attrs')
         return nil
      else -- delete required attributes from optionals list
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
            break
         end
      end

      if ncl_opt[i] ~= list_opt[j] then -- test optional attributes
         print ('wrong optional attrs')
         return nil
      end
   end

   local list_child = syntax.arg.children

   -- call this function recursively for each children
   for k in ipairs (ncl) do
      for i=1, #list_child do
         if ncl[k][0].tag == list_child[i] then
            filter.aply (ncl[k])
            break
         end
      end

      if ncl[k][0].tag ~= list_child[i] then -- test children
         print ('wrong children')
         return nil
      end
   end

   return TRUE

end

return filter
