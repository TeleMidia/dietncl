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
local type = type
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
   },
   importedDocumentBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'importNCL'}
   },
   ruleBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'importBase', 'compositeRule', 'rule'}
   },
   transitionBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'importBase', 'transition'}
   },
   regionBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id', 'device', 'region'},
      children = {'importBase', 'region'}
   },
   descriptorBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'importBase', 'descriptor', 'descriptorSwitch'}
   },
   connectorBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'importBase', 'causalConnector'}
   },
   meta = {
      parent = {'head', 'body', 'context'},
      required_attrs = {'name', 'content'},
      optional_attrs = nil,
      children = nil
   },
   metadata = {
      parent = {'head', 'body', 'context'},
      required_attrs = nil,
      optional_attrs = nil,
      children = nil
   },
   port = {
      parent = {'body', 'context'},
      required_attrs = {'id', 'component'},
      optional_attrs = {'interface'},
      children = nil
   },
   property = {
      parent = {'body', 'context', 'media'},
      required_attrs = nil,
      optional_attrs = {'name', 'value', 'externable'},
      children = nil
   },
   media = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'id'},
      optional_attrs = {'src', 'type', 'refer', 'instance', 'descriptor'},
      children = {'area', 'property'}
   },
   context = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'id'},
      optional_attrs = {'refer'},
      children = {'port', 'property', 'media', 'context', 'link', 'switch',
                  'meta', 'metadata'}
   },
   switch = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'id'},
      optional_attrs = {'refer'},
      children = {'defaultComponent', 'switchPort', 'bindRule', 'media',
                  'context', 'switch'}
   },
   link = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'xconnector'},
      optional_attrs = {'id'},
      children = {'linkParam', 'bind'}
   },
   importNCL = {
      parent = {'importedDocumentBase'},
      required_attrs = {'alias', 'documentURI'},
      optional_attrs = nil,
      children = nil
   },
   importBase = {
      parent = {'ruleBase', 'transitionBase', 'regionBase',
                'descriptorBase', 'connectorBase'},
      required_attrs = {'alias', 'documentURI'},
      optional_attrs = {'region', 'baseId'},
      children = nil
   },
   compositeRule = {
      parent = {'ruleBase', 'compositeRule'},
      required_attrs = {'id', 'operator'},
      optional_attrs = nil,
      children = {'compositeRule', 'rule'}
   },
   rule = {
      parent = {'ruleBase', 'compositeRule'},
      required_attrs = {'var', 'comparator', 'value'},
      optional_attrs = {'id'},
      children = nil
   },
   transition = {
      parent = {'transitionBase'},
      required_attrs = {'id', 'type'},
      optional_attrs = {'subtype', 'dur', 'startProgress', 'endProgress',
                        'direction', 'fadeColor', 'horzRepeat',
                        'vertRepeat', 'borderWidth', 'borderColor'},
      children = nil
   },
   region = {
      parent = {'regionBase', 'region'},
      required_attrs = {'id'},
      optional_attrs = {'title', 'left', 'right', 'top', 'bottom', 'height',
                        'width', 'zIndex'},
      children = {'region'}
   },
   descriptor = {
      parent = {'descriptorBase'},
      required_attrs = {'id'},
      optional_attrs = {'player', 'explicitDur', 'region', 'freeze',
                        'moveLeft', 'moveRight', 'moveUp', 'moveDown',
                        'focusIndex', 'focusBorderColor', 'focusBorderWidth',
                        'focusBorderTransparency', 'focusSrc', 'focusSelSrc',
                        'selBorderColor', 'transIn', 'transOut'},
      children = {'descriptorParam'}
   },
   descriptorSwitch = {
      parent = {'descriptorBase'},
      required_attrs = {'id'},
      optional_attrs = nil,
      children = {'defaultDescriptor', 'bindRule', 'descriptor'}
   },
   causalConnector = {
      parent = {'connectorBase'},
      required_attrs = {'id'},
      optional_attrs = nil,
      children = {'connectorParam', 'simpleCondition', 'compoundCondition',
                  'simpleAction', 'compoundAction'}
   },
   area = {
      parent = {'media'},
      required_attrs = {'id'},
      optional_attrs = {'coords', 'begin', 'end', 'beginText', 'endText',
                        'beginPosition', 'endPosition', 'first', 'last',
                        'label', 'clip'},
      children = nil
   },
   defaultComponent = {
      parent = {'switch', 'descriptorSwitch'},
      required_attrs = {'component'},
      optional_attrs = nil,
      children = nil
   },
   switchPort = {
      parent = {'switch'},
      required_attrs = {'id'},
      optional_attrs = nil,
      children = {'mapping'}
   },
   bindRule = {
      parent = {'switch', 'descriptorSwitch'},
      required_attrs = {'constituent', 'rule'},
      optional_attrs = nil,
      children = nil
   },
   linkParam = {
      parent = {'link'},
      required_attrs = {'name', 'value'},
      optional_attrs = nil,
      children = nil
   },
   bind = {
      parent = {'link'},
      required_attrs = {'role', 'component'},
      optional_attrs = {'interface', 'descriptor'},
      children = {'bindParam'}
   },
   descriptorParam = {
      parent = {'descriptor'},
      required_attrs = {'name', 'value'},
      optional_attrs = nil,
      children = nil
   },
   defaultDescriptor = {
      parent = {'descriptorSwitch'},
      required_attrs = {'descriptor'},
      optional_attrs = nil,
      children = nil
   },
   connectorParam = {
      parent = {'causalConnector'},
      required_attrs = {'name'},
      optional_attrs = {'type'},
      children = nil
   },
   simpleCondition = {
      parent = {'causalConnector', 'compoundCondition'},
      required_attrs = {'role'},
      optional_attrs = {'delay', 'eventType', 'key', 'transition', 'min',
                        'max', 'qualifier'},
      children = nil
   },
   compoundCondition = {
      parent = {'causalConnector', 'compoundCondition'},
      required_attrs = {'operator'},
      optional_attrs = {'delay'},
      children = {'simpleCondition', 'compoundCondition',
                  'assessmentStatement', 'compoundStatement'}
   },
   simpleAction = {
      parent = {'causalConnector', 'compoundAction'},
      required_attrs = {'role'},
      optional_attrs = {'delay', 'eventType', 'actionType', 'value', 'min',
                        'max', 'qualifier', 'repeat', 'repeatDelay',
                        'duration', 'by'},
      children = nil
   },
   compoundAction = {
      parent = {'causalConnector', 'compoundAction'},
      required_attrs = {'operator'},
      optional_attrs = {'delay'},
      children = {'simpleAction', 'compoundAction'}
   },
   mapping = {
      parent = {'switchPort'},
      required_attrs = {'component'},
      optional_attrs = {'interface'},
      children = nil
   },
   assessmentStatement = {
      parent = {'compoundCondition', 'compoundStatement'},
      required_attrs = {'comparator'},
      optional_attrs = nil,
      children = {'attributeAssessment', 'valueAssessment'}
   },
   compoundStatement = {
      parent = {'compoundCondition', 'compoundStatement'},
      required_attrs = {'operator'},
      optional_attrs = {'isNegated'},
      children = {'assessmentStatement', 'compoundStatement'}
   },
   attributeAssessment = {
      parent = {'assessmentStatement'},
      required_attrs = {'role', 'eventType'},
      optional_attrs = {'key', 'attributeType', 'offset'},
      children = nil
   },
   valueAssessment = {
      parent = {'assessmentStatement'},
      required_attrs = {'value'},
      optional_attrs = nil,
      children = nil
   }
}

---
-- The CHECK NCL filter checks if the file is a valid NCL document or not.
-- @param ncl NCL Document.
-- @return NCL document or an error message.
---
function filter.apply (ncl)

   local index
   local arg = ncl[0].tag

   if type (syntax[arg]) ~= 'table' then -- test tag
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

      if syntax[arg].parent[index] ~= ncl[0].parent[0].tag then -- test parent
         print ('wrong parent')
         return nil
      end
   end

   local ncl_opt = {}

   for k in pairs (ncl) do -- build optional attributes table
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

   for i=1, #list_req do -- test required attributes
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

      if ncl_opt[i] ~= list_opt[index] then -- test optional attributes
         print ('wrong optional attrs')
         return nil
      end
   end

   local list_child = syntax[arg].children

   -- call this function recursively for each children
   for k in ipairs (ncl) do
      for i=1, #list_child do
         if ncl[k][0].tag == list_child[i] then
            filter.apply (ncl[k])
            index = i
            break
         end
      end

      if ncl[k][0].tag ~= list_child[index] then -- test children
         print ('wrong children')
         return nil
      end
   end

   return ncl

end

return filter
