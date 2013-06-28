-- import.lua -- Resolves document importation.
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

-- The 'import' filter resolves the external references and removes the
-- <importNCL>, <importBase>, and <importedDocumentBase> elements from a
-- given document.  This filter has no dependencies.

require ('dietncl.xmlsugar')
local xml     = xml
local dietncl = require ('dietncl')
local path    = require ('dietncl.path')
local assert  = assert
local ipairs  = ipairs
module (...)

-- List of possible <importBase> parents.
local importbase_parent_list = {
   'connectorBase',
   'descriptorBase',
   'regionBase',
   'ruleBase',
   'transitionBase',
}

local _importbase_parent_list = {}
for _,s in ipairs (importbase_parent_list) do
   _importbase_parent_list[s] = true
end

-- Returns true if tag-name TAG is a possible <importBase> parent.

local function is_importbase_parent (tag)
   return _importbase_parent_list[tag]
end

-- List of XML-IDREF attributes indexed by tag-name.
--
-- IMPORTANT: We do not list the descriptor attributes 'transIn' and
-- 'transOut' here because these require a special treatment -- i.e., their
-- value is not XML-IDREFs in the strict sense; their value is a semicolon
-- separated list of XML-IDREFs.  (Cf. the update_id_and_idref() function
-- for details.)
local idref_attribute_table = {
   bind             = {'component'},
   bindRule         = {'constituent', 'rule'},
   context          = {'refer'},
   defaultComponent = {'component'},
   descriptor       = {'region' },
   mapping          = {'component'},
   media            = {'descriptor', 'refer'},
   port             = {'component'},
   switch           = {'refer'},
}

-- Concatenates the string 'ALIAS#' to the XML-ID or XML-IDREF attributes of
-- all elements in tree E.

local function update_id_and_idref (e, alias)
   local tag = e:tag ()
   if e.id then
      e.id = alias..'#'..e.id
   end

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

   for _,attr in ipairs (idref_attribute_table[tag] or {}) do
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
-- string 'ALIAS#' to the XML-ID and XML-IDREF attributes of the copied
-- elements.
--
-- If the specified base is a <regionBase> and the parameters REGION and
-- BASEID are given, then:
--  * REGION is the XML-ID of the <region> element under which the imported
--    elements should be inserted; and
--  * BASEID is the XML-ID of the <regionBase> element that should be
--    imported.
-- Otherwise, the parameters REGION an BASEID are ignored.
--
-- Returns true if successful, otherwise returns false plus error message.

local function import_base (e, ext, alias, region, baseid)
   local ncl                    -- pointer to NCL document
   local tag                    -- tag-name of base E
   local list                   -- list of bases in EXT to be processed

   ncl = xml.parent (e:parent ())
   tag = e:tag ()
   assert (is_importbase_parent (tag))

   if tag == 'regionBase' and region then
      e = assert (ncl:match ('region', 'id', region))
   end

   if tag == 'regionBase' and baseid then
      list = {ext:match (tag, 'id', baseid)}
      assert (#list == 1)
   else
      list = {ext:match (tag)}
   end

   if #list == 0 then
      return true               -- nothing to do
   end

   for _,base in ipairs (list) do
      base = base:clone ()
      update_id_and_idref (base, alias)
      for x in base:children () do
         e:insert (x)
      end
   end

   return true
end

-- Applies the import filter to the document at path name URI.
-- NCL is the pointer to the host document.
-- Returns a pointer to the external document if successful,
-- otherwise returns nil plus error message.

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

-- Resolves <importBase> element E.
-- Returns true if successful, otherwise returns false plus error message.

local function resolve_importbase (ncl, e)
   local parent                 -- pointer to E's parent
   local ext                    -- pointer to external document
   local err                    -- error message
   local status

   parent = e:parent ()

   assert (e:tag () == 'importBase')
   assert (is_importbase_parent (parent:tag ()))
   assert (e.alias)
   assert (e.documentURI)

   ext, err = resolve_external_document (ncl, e.documentURI)
   if ext == nil then
      return false, err
   end

   status, err = import_base (parent, ext, e.alias, e.region, e.baseId)
   if status == false then
      return false, err
   end

   parent:remove (e)
   return true
end

-- Resolves <importNCL> element E.
-- Returns true if successful, otherwise returns false plus error message.

local function resolve_importncl (ncl, e)
   local parent                 -- pointer to E's parent
   local ext                    -- pointer to external document
   local err                    -- error message
   local status

   parent = e:parent ()

   assert (e:tag () == 'importNCL')
   assert (parent:tag () == 'importedDocumentBase')
   assert (e.alias)
   assert (e.documentURI)

   ext, err = resolve_external_document (ncl, e.documentURI)
   if ext == nil then
      return false, err
   end

   -- Import all bases of the external document.
   for _,tag in ipairs (importbase_parent_list) do
      local base = ncl:match (tag)
      if base == nil then
         base = xml.new (tag)
         ncl:match ('head'):insert (base)
      end
      status, err = import_base (base, ext, e.alias)
      if status == false then
         return false, err
      end
   end

   -- Import the components (media, contexts, or switches) of the external
   -- document that are referenced by the host document.
   for x in ncl:gmatch (nil, 'refer') do
      local tag = x:tag ()
      assert (tag == 'media' or tag == 'context' or tag == 'switch')

      if tag == 'media' and x.instance and x.instance ~= 'new' then
         goto continue          -- nothing to do
      end

      local refer = x.refer:match ('^'..e.alias..'#(.*)$')
      if refer == nil then
         goto continue          -- nothing to do
      end

      local y = ext:match (tag, 'id', refer)
      y = y:clone ()
      y.id = x.id
      update_id_and_idref (y, e.alias)

      xml.replace (x:parent (), x, y)
      :: continue ::
   end

   xml.remove (parent, e)
   return true
end


-- Exported functions.

function apply (ncl)
   local status
   local err

   for e in ncl:gmatch ('importBase') do
      status, err = resolve_importbase (ncl, e)
      if status == false then
         return nil, err
      end
   end

   for e in ncl:gmatch ('importNCL') do
      status, err = resolve_importncl (ncl, e)
      if status == false then
         return nil, err
      end
   end

   local e = ncl:match ('importedDocumentBase')
   if e then
      xml.remove (e:parent (), e)
   end

   return ncl
end
