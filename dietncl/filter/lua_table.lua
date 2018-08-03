--[[ filter.lua_table -- Convert NCL Document into NCL-ltab.
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

local filter = {}

local print = print
local ipairs = ipairs
local pairs = pairs
local table = table
local type = type

local xml = require('dietncl.xmlsugar')
local penlight = require('pl.pretty')

_ENV = nil

---
-- Transform a simplified NCL program into a lua table
-- statement.
--
-- Dependencies: `dietncl.filter.prenorm4`
-- @module dietncl.filter.lua_table
---

--------------------------------------------------
-- Forward Declaration
local parser_table = {}


--------------------------------------------------
-- NCL-ltab index table
local index_table = {
   -- context
   ['property'] = 3,
   ['port'] = 4,
   ['context'] = 5,
   ['switch'] = 5,
   ['media'] = 5,
   ['link'] = 6,

   -- media
   -- ['property'] = 3
   ['area'] = 4}


--------------------------------------------------
-- Operand conversion table
local operand_table = {
   ['eq'] = '==',
   ['ne'] = '~=',
   ['gt'] = '>',
   ['lt'] = '<',
   ['gte'] = '>=',
   ['lte'] = '<='}


--------------------------------------------------
-- Transition table converter
local transition_table = {
   -- simpleCondition transitions
   ['onBegin'] = 'start',
   ['onEnd'] = 'stop',
   ['onAbort'] = 'abort',
   ['onPause'] = 'pause',
   ['onResume'] = 'resume',
   ['onSelection'] = 'start',
   ['onBeginSelection'] = 'start',
   ['onEndSelection'] = 'stop',
   ['onAbortSelection'] = 'abort',
   ['onPauseSelection'] = 'pause',
   ['onResumeSelection'] = 'resume',
   ['onBeginAttribution'] = 'start',
   ['onEndAttribution'] = 'stop',
   ['onAbortAttribution'] = 'abort',
   ['onPauseAttribution'] = 'pause',
   ['onResumeAttribution'] = 'resume',

   -- simpleAction transitions
   ['start'] = 'start',
   ['stop'] = 'stop',
   ['abort'] = 'abort',
   ['pause'] = 'pause',
   ['resume'] = 'resume',
   ['set'] = 'start'}


--------------------------------------------------
-- Auxiliary functions
-- (metadata parsing)

-- Create new element
local function new(ltab, parent, ncl)
   ltab['parent'] = parent
   ltab['ncl'] = ncl
   ltab['cache'] = {}
end


-- Find element ltab looking up
local function find(ltab, tag)
   if ltab['parent'] == nil then
      return nil
   elseif ltab['parent'][1] == tag then
      return ltab['parent']
   end

   return find(ltab['parent'], tag)
end


-- Clean all metadata
local function clean(ltab)
   -- clear table
   ltab['parent'] = nil
   ltab['cache'] = nil
   ltab['ncl'] = nil

   -- recursive parsing
   for _, v in ipairs(ltab) do
      if type(v) == 'table' then
         clean(v)
      end
   end
end


--------------------------------------------------
-- Parsing functions

-- Resolve event id
local function get_event(elt, context, ltab)
   if ltab['cache'][elt['id']] then
      -- check for cache
      return ltab['cache'][elt['id']]
   elseif elt['interface'] == nil then
      -- whole object presentation
      return elt['component'] .. '@lambda'
   end

   local comp = context:find(nil, 'id', elt['component'])
   local inter = comp:find(nil, 'name', elt['interface'])

   if inter ~= nil then
      -- context or media property
      return elt['component'] .. '.' .. elt['interface']
   elseif comp:tag() == 'media' then
      -- media area
      return elt['component'] .. '@' .. elt['interface']
   else
      -- nested port
      inter = comp:find(nil, 'id', elt['interface'])
      return get_event(inter, comp, ltab)
   end
end


-- port
local function parse_port(port, ltab)
   -- {evt-id}
   local context = find(ltab, 'context')

   -- get event from port
   local event = get_event(port, context['ncl'], context)

   -- store cache for later usage
   context['cache'][port['id']] = event

   -- append to port table only if presentation event
   if event:find('@') then
      table.insert(ltab, event)
   end
end


-- property
local function parse_property(property, ltab)
   -- {name = value}
   ltab[property['name']] = property['value']
end


-- area
local function parse_area(area, ltab)
   local area_tab = {}

   if area['label'] ~= nil then
      -- {id, label}
      area_tab[1] = area['id']
      area_tab[2] = area['label']
   else
      -- {id, time-spec, time-spec}
      area_tab[1] = area['id']
      area_tab[2] = area['begin']
      area_tab[3] = area['end']
   end

   -- append to area list
   table.insert(ltab, area_tab)
end


-- media
local function parse_media(media, ltab)
   -- {tag, id, properties, area}
   local med = {'media', media['id'], {}, {}}

   for attr in media:attributes() do
      if attr ~= 'id' then
         med[3][attr] = media[attr]
      end
   end

   for child in media:children() do
      local tag = child:tag()
      local fn = parser_table[tag]
      fn(child, med[index_table[tag]])
   end

   table.insert(ltab, med)
end


-- predicate
local function parse_predicate(predicate, link, ltab)
   -- {left, comp, right}
   ltab[2] = operand_table[predicate['comparator']]

   local i = 1
   -- iterate through assessmentStatements
   for child in predicate:children() do
      local context = find(ltab, 'context')
      local bind = link:find('bind', 'role', child['role'])

      -- get event from bind
      ltab[i] = get_event(bind, context['ncl'], context)
      i = 3
   end
end


-- nested predicate
local function parse_nested_predicate(predicate, link, ltab)
   -- {'not', pred}
   -- {('and'|'or'), pred, pred}
   if predicate['isNegated'] then
      ltab = {'not', {}}
   else
      ltab = {predicate['operator'], {}, {}}
   end

   local i = 2
   for child in predicate:children() do
      local pred = condition:find('compoundStatement')
      if pred == nil then
         pred = condition:find('assessmentStatement')
         parse_predicate(pred, link, ltab[i])
      else
         parse_nested_predicate(pred, link, ltab[i])
      end

      i = 3
   end
end


-- simple condition/action
local function parse_action(action, link, ltab)
   -- insert transition
   table.insert(ltab, transition_table[action['role']])

   local context = find(ltab, 'context')
   local bind = link:find('bind', 'role', action['role'])

   -- get event from bind
   local event = get_event(bind, context['ncl'], context)

   -- append to condition/action table
   table.insert(ltab, event)
end


-- condition
local function parse_compound_condition(condition, link, ltab)
   -- {transition, evt-id, [predicate]}
   local cond = {}
   new(cond, ltab, condition)

   -- get transition and evt-id
   local simple_cond = condition
   if simple_cond:tag() ~= 'simpleCondition' then
      simple_cond = simple_cond:find('simpleCondition')
   end
   parse_action(simple_cond, link, cond)

   -- create predicate table
   cond[3] = {}
   new(cond[3], cond)

   -- get predicate
   local pred = condition:find('compoundStatement')
   if pred == nil then
      pred = condition:find('assessmentStatement')

      if pred == nil then
         -- if no predicate
         table.insert(cond[3], true)
      else
         -- simple predicate
         parse_predicate(pred, link, cond[3])
      end
   else
      -- compound predicate
      parse_nested_predicate(pred, link, cond[3])
   end

   -- append to condition list
   table.insert(ltab, cond)
end


-- action
local function parse_compound_action(action, link, ltab)
   -- {transition, evt-id, [params]}
   local act = {}
   new(act, ltab, action)

   -- get transition and evt-id
   local simple_act = action
   if simple_act:tag() ~= 'simpleAction' then
      simple_act = simple_act:find('simpleAction')
   end
   parse_action(simple_act, link, act)

   -- [params]??
   -- só existe se for um 'set'?

   -- append to condition list
   table.insert(ltab, act)
end


-- link
local function parse_link(link, ltab)
   -- {{conditions}, {actions}}
   local condition_list = {}
   local action_list = {}
   local link_tab = {condition_list, action_list}

   -- save metadata
   new(link_tab, ltab, link)
   new(condition_list, link_tab)
   new(action_list, link_tab)

   -- get root
   local ncl = link:parent()
   while ncl:tag() ~= 'ncl' do
      ncl = ncl:parent()
   end

   -- find connector from root
   local head = ncl:find('head')
   local conn = head:find(nil, 'id', link['xconnector'])

   -- parse conditions
   local cond = conn:find('compoundCondition')
      or conn:find('simpleCondition')
   parse_compound_condition(cond, link, condition_list)

   -- parse actions
   local act = conn:find('compoundAction')
      or conn:find('simpleAction')
   parse_compound_action(act, link, action_list)

   -- append to link list
   table.insert(ltab, link_tab)
end


-- context
local function parse_context(context, ltab)
   -- {tag, id, props, ports, children, links}
   local ctx = {'context', context['id'], {}, {}, {}, {}}
   new(ctx, ltab, context)

   -- parse children
   for child in context:children() do
      local tag = child:tag()
      local fn = parser_table[tag]

      -- save metadata
      new(ctx[index_table[tag]], ctx)

      -- call corresponding parse function
      fn(child, ctx[index_table[tag]])
   end

   -- not root
   if ltab ~= nil then
      -- save metadata
      local parent_ctx = find(ctx, 'context')

      for k, v in pairs(ctx['cache']) do
         parent_ctx['cache'][k] = v
      end

      -- append to children table
      table.insert(ltab, ctx)
   end
   return ctx
end


--------------------------------------------------
-- NCL parse table
parser_table = {
   ['port'] = parse_port,
   ['property']= parse_property,
   ['area']= parse_area,
   ['media'] = parse_media,
   ['context'] = parse_context,
   ['link'] = parse_link}


--------------------------------------------------
-- Final filter

-- Filter that creates a lua table from the conversion of a micro ncl
function filter.apply(ncl)
   local body = ncl:find('body')
   local ltab = parse_context(body)

   -- clean metadata
   clean(ltab)

   -- debug
   -- penlight.dump(ltab)

   return ltab
end

return filter
