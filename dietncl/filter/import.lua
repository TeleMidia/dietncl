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

-- This filter resolves document importation.  It removes all <importNCL>,
-- <importBase>, and <importedDocumentBase> tags from the host document.

require ('dietncl.xmlsugar')
local xml     = xml
local dietncl = require ('dietncl')
local errmsg  = require ('dietncl.errmsg')
local path    = require ('dietncl.path')

local _G     = _G
local assert = assert
local ipairs = ipairs
local pairs  = pairs
local table  = table
module (...)

-- List of possible parents for <importBase>.
local importbase_parent_list = {
   connectorBase  = true,
   descriptorBase = true,
   regionBase     = true,
   ruleBase       = true,
   transitionBase = true,
}

-- Table mapping an element to a list containing its XML-IDREF attributes.
-- We do not list the <descriptor> attributes 'transIn' and 'transOut' here
-- because these require a special treatment.  Cf. update_id_and_idref().
local idref_attribute_table = {
   bind             = {'component'},
   bindRule         = {'constituent', 'rule'},
   context          = {'refer'},
   defaultComponent = {'component'},
   descriptor       = {'region' },
   mapping          = {'component'},
   media            = {'descriptor', 'refer'},
   port             = {'component'},
   switch           = {'refer'}
}

-- Removes element E from its parent.
-- Returns the index of the removed element if successful,
-- otherwise returns nil.
local function remove_from_parent (e)
   local parent = e:parent ()
   if parent == nil then
      return nil
   end
   local index = nil
   for i=1,#parent do
      if parent[i] == e then
         index = i
      end
   end
   if index == nil then
      return nil
   end
   parent:remove (index)
   return index
end

-- Concatenates the string 'ALIAS#' to the attributes in tree E
-- such that their value is an XML-ID or XML-IDREF.
local function update_id_and_idref (e, alias)
   if e.id ~= nil then
      e.id = alias..'#'..e.id
   end
   local tag = assert (e:tag ())
   if tag == 'descriptor' then
      --
      -- Special treatment for 'transIn' and 'transOut'.
      -- This is nasty, I know...
      --
      for _,s in ipairs ({ 'transIn', 'transOut' }) do
         if e[s] then
            e[s] = e[s]:gsub ('%s', '')
            e[s] = e[s]:gsub ('([^;]+)', alias..'#%1')
         end
      end
   end
   local list = idref_attribute_table[tag]
   for _,attr in ipairs (list or {}) do
      if e[attr] then
         e[attr] = alias..'#'..e[attr]
      end
   end
   for i=1,#e do
      update_id_and_idref (e[i], alias)
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
-- Returns true if successful, otherwise returns false plus error message.
local function import_base (e, ext, alias, region, baseid)
   local ncl = assert (e:parent ())
   ncl = assert (ncl:parent ())
   assert (ncl:tag () == 'ncl')

   local tag = assert (e:tag ())
   assert (importbase_parent_list [tag])

   local list
   if tag == 'regionBase' then
      if region then
         e = ncl:match ('region', 'id', region)
         if e == nil then
            return false, errmsg.badidref (tag, 'region', region)
         end
      end
      if baseid then
         list = {ext:match (tag, 'id', baseid)}
         if #list == 0 then
            return false, errmsg.badidref (tag, 'baseId', baseid)
         elseif #list > 1 then
            return false, errmsg.dupid (tag, baseid)
         end
      else
         -- Import all region bases.
         list = {ext:match (tag)}
      end
   else
      -- Import the *FIRST* (non-region) base found.
      list = {}
      list[1] = ext:match (tag)
   end

   if #list == 0 then
      return true               -- nothing to do
   end

   for _, ext in ipairs (list) do
      ext = ext:clone ()
      update_id_and_idref (ext, alias)
      for x in ext:children () do
         e:insert (x)
      end
   end

   return true
end

-- Applies the import filter to the document at path name URI.
-- NCL is the handle of the host document -- this is used to resolve
-- relative path names.
--
-- Returns a handle to the external document if successful.
-- Otherwise returns nil plus error message.
local function resolve_external_document (ncl, uri)
   local pathname = uri
   if path.relative (uri) then
      local dir = ncl:getuserdata ('pathname') or ''
      pathname = assert (path.join (dir, uri))
   end
   local ext, err = dietncl.parse (pathname)
   if ext == nil then
      return nil, err
   end
   ext, err = apply (ext)
   if ext == nil then
      return nil, err
   end
   return ext
end

-- Resolve <importBase> element E.
-- Returns true if successful, otherwise returns false plus error message.
local function resolve_importbase (ncl, e)
   assert (e:tag () == 'importBase')

   -- Check parent.
   local parent = assert (e:parent ())
   local tag = assert (parent:tag ())
   if not importbase_parent_list[tag] then
      return false, errmsg.badparent ('importBase', tag)
   end

   -- Check required attributes.
   if e.alias == nil then
      return false, errmsg.attrmissing ('importBase', 'alias')
   end
   if e.documentURI == nil then
      return false, errmsg.attrmissing ('importBase', 'documentURI')
   end

   -- Resolve the external document.
   local ext, err = resolve_external_document (ncl, e.documentURI)
   if ext == nil then
      return false, err
   end

   -- Import the external base.
   local status, err = import_base (parent, ext,
                                    e.alias, e.region, e.baseId)
   if status == false then
      return false, err
   end

   -- Remove the resolved <importBase> element.
   remove_from_parent (e)

   -- All done.
   return true
end

-- Resolve <importNCL> element E.
-- Returns true if successful, otherwise returns false plus error message.
local function resolve_importncl (ncl, e)
   assert (e:tag () == 'importNCL')

   -- Check parent.
   local parent = assert (e:parent ())
   local tag = assert (parent:tag ())
   if tag ~= 'importedDocumentBase' then
      return false, errmsg.badparent ('importNCL', tag)
   end

   -- Check required attributes.
   if e.alias == nil then
      return false, errmsg.attrmissing ('importNCL', 'alias')
   end
   if e.documentURI == nil then
      return false, errmsg.attrmissing ('importNCL', 'documentURI')
   end

   -- Resolve the external document.
   local ext, err = resolve_external_document (ncl, e.documentURI)
   if ext == nil then
      return false, err
   end

   -- Import all bases of the external document.
   local list = {}
   for tag,_ in pairs (importbase_parent_list) do
      list[#list+1] = tag
   end
   table.sort (list)
   for _,tag in ipairs (list) do
      local base = ncl:match (tag)
      if not base then
         base = xml.new (tag)
         assert (ncl:match ('head')):insert (base)
      end
      local status, err = import_base (base, ext, e.alias)
      if status == false then
         return false, err
      end
   end

   -- Import all <media>, <context>, and <switch> of the external document
   -- that are referenced by the host document.
   for m in ncl:gmatch (nil, 'refer') do
      local tag = m:tag ()
      if tag ~= 'media' and tag ~= 'context' and tag ~= 'switch' then
         goto continue          -- nothing to do
      end
      if tag == 'media' and m.instance and m.instance ~= 'new' then
         goto continue          -- nothing to do
      end
      local id = m.id
      if id == nil then
         return false, errmsg.attrmissing (tag, 'id')
      end
      local refer = m.refer:match ('^'..e.alias..'#(.*)$')
      local mref = ext:match (tag, 'id', refer)
      if mref == nil or mref:tag () ~= tag then
         return false, errmsg.badidref (tag, 'refer', refer)
      end
      local parent = m:parent ()
      local i = assert (remove_from_parent (m))
      mref = assert (mref:clone ())
      update_id_and_idref (mref, e.alias)
      mref.id = id
      parent:insert (i, mref)
      :: continue ::
   end

   -- Remove the resolved <importNCL> element.
   remove_from_parent (e)

   -- All done.
   return true
end


-- Exported functions.

function apply (ncl)
   for e in ncl:gmatch ('importBase') do
      local status, err = resolve_importbase (ncl, e)
      if status == false then
         return nil, err
      end
   end
   for e in ncl:gmatch ('importNCL') do
      local status, err = resolve_importncl (ncl, e)
      if status == false then
         return nil, err
      end
   end
   local e = ncl:match ('importedDocumentBase')
   if e then
      remove_from_parent (e)
   end
   return ncl
end
