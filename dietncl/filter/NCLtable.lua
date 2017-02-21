--[[ filter.NCLtable -- Table with NCL elements.
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

_ENV = nil

---
-- Table with NCL elements from 'handbook.ncl.org' to be exported
-- to the check_ncl filter.
--
-- @module dietncl.filter.NCLtable
---

local syntax = {
   ncl = {
      parent = nil,
      required_attrs = {'id'},
      optional_attrs = {'title', 'xmlns'},
      children =
         {op = ',',
          {op = '?',
           {'head'}},
          {op = '?',
           {'body'}}}
   },

   head = {
      parent = {'ncl'},
      required_attrs = nil,
      optional_attrs = nil,
      children =
         {op = ',',
          {op = '?',
           {'importedDocumentBase'}},
          {op = '?',
           {'ruleBase'}},
          {op = '?',
           {'transitionBase'}},
          {op = '*',
           {'regionBase'}},
          {op = '?',
           {'descriptorBase'}},
          {op = '?',
           {'connectorBase'}},
          {op = '*',
           {'meta'}},
          {op = '*',
           {'metadata'}}}
   },

   body = {
      parent = {'ncl'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children =
         {op = '*',
          {op = '|',
           {'port', 'property', 'media', 'context', 'switch', 'link',
            'meta', 'metadata'}}}
   },

   importedDocumentBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children =
         {op = '+',
          {'importNCL'}}
   },

   ruleBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children =
         {op = '+',
          {op = '|',
           {'importBase', 'compositeRule', 'rule'}}}
   },

   transitionBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children =
         {op = '+',
          {op = ',',
           {'importBase', 'transition'}}}
   },

   regionBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id', 'device', 'region'},
      children =
         {op = '+',
          {op = '|',
           {'importBase', 'region'}}}
   },

   descriptorBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children =
         {op = '+',
          {op = '|',
           {'importBase', 'descriptor', 'descriptorSwitch'}}}
   },

   connectorBase = {
      parent = {'head'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children =
         {op = '*',
          {op = '|',
           {'importBase', 'causalConnector'}}}
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
      children =
         {op = '*',
          {op = '|',
           {'area', 'property'}}}
   },

   context = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'id'},
      optional_attrs = {'refer'},
      children =
         {op = '*',
          {op = '|',
           {'port', 'property', 'media', 'context', 'link', 'switch',
            'meta', 'metadata'}}}
   },

   switch = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'id'},
      optional_attrs = {'refer'},
      children =
         {op = ',',
          {op = '?',
           {'defaultComponent'}},
          {op = '*',
           {'switchPort', 'bindRule', 'media', 'context', 'switch'}}}
   },

   link = {
      parent = {'body', 'context', 'switch'},
      required_attrs = {'xconnector'},
      optional_attrs = {'id'},
      children =
         {op = ',',
          {op = '*',
           {'linkParam'}},
          {op = '+',
           {'bind'}}}
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
      children =
         {op = '+',
          {op = '|',
           {'compositeRule', 'rule'}}}
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
      children =
         {op = '*',
          {'region'}}
   },

   descriptor = {
      parent = {'descriptorBase'},
      required_attrs = {'id'},
      optional_attrs = {'player', 'explicitDur', 'region', 'freeze',
                        'moveLeft', 'moveRight', 'moveUp', 'moveDown',
                        'focusIndex', 'focusBorderColor', 'focusBorderWidth',
                        'focusBorderTransparency', 'focusSrc', 'focusSelSrc',
                        'selBorderColor', 'transIn', 'transOut'},
      children =
         {op = '*',
          {'descriptorParam'}}
   },

   descriptorSwitch = {
      parent = {'descriptorBase'},
      required_attrs = {'id'},
      optional_attrs = nil,
      children =
         {op = ',',
          {op = '?',
           {'defaultDescriptor'}},
          {op = '*',
           {op = '|',
            {'bindRule', 'descriptor'}}}}
   },

   causalConnector = {
      parent = {'connectorBase'},
      required_attrs = {'id'},
      optional_attrs = nil,
      children =
         {op = ',',
          {op = '*',
           {'connectorParam'}},
          {op = '!',
           {op = '|',
            {'simpleCondition', 'compoundCondition'}}},
          {op = '!',
           {op = '|',
            {'simpleAction', 'compoundAction'}}}}
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
      children =
         {op = '+',
          {'mapping'}}
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
      children =
         {op = '*',
          {'bindParam'}}
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
      children =
         {op=',',
          {op='+',
           {op='|',
            {'simpleCondition', 'CompoundCondition'}}},
          {op='*',
           {op='|',
            {'assessmentStatement', 'compoundStatement'}}}}
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
      children =
         {op = '+',
          {op = '|',
           {'simpleAction', 'compoundAction'}}}
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
      children =
         {op = ',',
          {op = '!',
           {'attributeAssessment'}},
          {op = '!',
           {op = '|',
            {'attributeAssessment', 'valueAssessment'}}}}
   },

   compoundStatement = {
      parent = {'compoundCondition', 'compoundStatement'},
      required_attrs = {'operator'},
      optional_attrs = {'isNegated'},
      children =
         {op = '+',
          {op = '|',
           {'assessmentStatement', 'compoundStatement'}}}
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

return syntax
