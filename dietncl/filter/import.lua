-- import.lua -- Resolve document importation.
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

-- This filter resolves document importation via <importNCL> and
-- <importBase> tags.  The resulting document contain no <importNCL>,
-- <importBase>, or <importedDocumentBase> tags.

require ('dietncl.xmlsugar')
local xml     = xml
local dietncl = require ('dietncl')
local errmsg  = require ('dietncl.errmsg')
local path    = require ('dietncl.path')

local _G     = _G
local assert = assert
local ipairs = ipairs
local unpack = table.unpack
module (...)

-- List of possible parents for <importBase>.
local importbase_parent_list = {
   connectorBase  = true,
   descriptorBase = true,
   regionBase     = true,
   ruleBase       = true,
   transitionBase = true,
}

-- Concatenate the string 'ALIAS#' to the attributes of E whose value is an
-- XML-ID or XML-IDREF.
local function head_update_id_and_idref (e, alias)
   if e.id ~= nil then
      e.id = alias..'#'..e.id
   end
   if e:tag () == 'descriptor' then
      if e.region then
         e.region = alias..'#'..e.region
      end
      for _,s in ipairs ({ 'transIn', 'transOut' }) do
         if e[s] then
            e[s] = e[s]:gsub ('%s', '')
            e[s] = e[s]:gsub ('([^;]+)', alias..'#%1')
         end
      end
   end
end

-- Copies all elements of the specified base of external document EXT and
-- inserts them into element E of the host document.  Moreover, prefix the
-- string 'ALIAS#' to id of the copied elements.
--
-- If the specified base is a <regionBase> then:
--  * REGION contains the ID of the <region> element under which the
--    imported elements should be inserted; and
--  * BASEID contains the ID of the <regionBase> element that should be
--    imported.
-- Otherwise, the parameters REGION an BASEID are ignored.
--
-- Returns E if successful, otherwise returns nil plus error message.
local function import_base (e, ext, alias, region, baseid)
   local ncl = assert (e:parent ())
   ncl = assert (ncl:parent ())
   assert (ncl:tag () == 'ncl')

   local tag = assert (e:tag ())
   assert (importbase_parent_list [tag])

   if region then
      assert (tag == 'regionBase')
      e = unpack (ncl:match ('region', 'id', region))
      if e == nil then
         return nil, errmsg.badidref (tag, 'region', region)
      end
   end

   if baseid then
      assert (tag == 'regionBase')
      ext = unpack (ext:match (tag, 'id', baseid))
      if ext == nil then
         return nil, errmsg.badidref (tag, 'baseId', baseid)
      end
   else
      ext = unpack (ext:match (tag))
   end

   if not ext then
      return ncl                -- nothing to do
   end

   ext = ext:clone ()
   ext:walk (function (e) head_update_id_and_idref (e, alias) end)
   for x in ext:children () do
      e:insert (x)
   end

   return ncl
end

-- Resolve <importBase> element E.
-- Returns true if successful, otherwise returns false plus error message.
local function resolve_importbase (ncl, e)
   assert (e:tag () == 'importBase')

   -- Check attributes.
   if e.alias == nil then
      return false, errmsg.attrmissing ('importBase', 'alias')
   end
   if e.documentURI == nil then
      return false, errmsg.attrmissing ('importBase', 'documentURI')
   end

   -- Resolve the imported document.
   local pathname = e.documentURI
   if path.relative (e.documentURI) then
      local dir = ncl:getuserdata ('pathname') or ''
      pathname = assert (path.join (dir, e.documentURI))
   end
   local ext, err = dietncl.parse (pathname)
   if ext == nil then
      return false, err
   end
   ext, err = apply (ext)
   if ext == nil then
      return false, err
   end

   -- Check parent.
   local base = assert (e:parent ())
   local tag = assert (base:tag ())
   if not importbase_parent_list[tag] then
      return false, errmsg.badparent ('importBase', tag)
   end

   -- Import the elements of the external document.
   local ncl, err = import_base (base, ext, e.alias, e.region, e.baseId)
   if ncl == nil then
      return false, err
   end

   -- Remove <importBase> element.
   local index = nil
   for i=1,#base do
      if base[i] == e then
         index = i
      end
   end
   base:remove (assert (index))

   -- All done.
   return ncl
end


-- Exported functions.

function apply (ncl)
   for _,e in _G.ipairs (ncl:match ('importBase')) do
      local status, errmsg = resolve_importbase (ncl, e)
      if status == false then
         return nil, errmsg
      end
   end
   return ncl
end
