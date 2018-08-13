--[[ Copyright (C) 2013-2017 PUC-Rio/Laboratorio TeleMidia

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
local pairs = pairs
local type = type
local print = print

local dietncl = require ('dietncl')
local filter = require ('dietncl.filter.lua_table')

local penlight = require('pl.pretty')

_ENV = nil


--------------------------------------------------
-- TODO:

-- add a test with a switch

-- explain switch syntax
--------------------------------------------------

-- Table syntax explanation

local ltab = {
   -- tag
   'context',

   -- id
   'ctx',

   -- properties
   {
      -- name = value
      prop = '5'
   },

   -- ports
   {
      -- event
      'm1@lambda'
   },

   -- childrens
   {
      -- media
      {
         -- tag
         'media',

         -- id
         'child1',

         -- properties
         {},

         -- areas
         {
            -- first area
            {
               -- id
               'a1',

               -- start
               '1s',

               -- end
               '2s'
            }
         }
      },

      -- switch
      {
         -- tag
         'switch',

         -- id
         'child2',

         -- children
         {},

         -- rules
         {
            -- id
            'rule1',

            -- predicate
            {true}
         }
      },

      -- context
      {'context', 'child3', {}, {}, {}, {}}
   },

   -- links
   {
      -- first link
      {
         -- condition list
         {
            -- first condition
            {
               -- transition
               'stop',

               -- event
               'child1@lambda',

               -- predicate
               {true}
            }
         },

         -- action list
         {
            -- first action
            {
               -- transition
               'start',

               -- event
               'child1@lambda'
            }
         }
      }
   }
}


--------------------------------------------------

-- Auxiliary function to compare tables
local function deepcompare(t1, t2)
   -- check types
   local ty1 = type(t1)
   local ty2 = type(t2)
   if ty1 ~= ty2 then
      return false
   end

   -- non-table types can be directly compared
   if ty1 ~= 'table' and ty2 ~= 'table' then
      return t1 == t2
   end

   -- check all fields in both tables
   for k1,v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil or not deepcompare(v1,v2) then
         return false
      end
   end
   for k2,v2 in pairs(t2) do
      local v1 = t1[k2]
      if v1 == nil or not deepcompare(v1,v2) then
         return false
      end
   end

   return true
end


--------------------------------------------------

-- Simple NCL

local str = [[
<ncl>
  <head>
  </head>
  <body id='b'>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local ltab = filter.apply (ncl)
assert(ltab)

local result = {'context', 'b',
                {},
                {},
                {},
                {}
}

assert (deepcompare(ltab, result))


--------------------------------------------------

-- Link using a chain of ports to reference a property

local str = [[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c1'>
        <compoundCondition operator='and'>
          <simpleCondition role='onEnd'/>
          <assessmentStatement comparator='eq'>
            <attributeAssessment role='left' eventType='attribution'/>
            <attributeAssessment role='right' eventType='attribution'/>
          </assessmentStatement>
        </compoundCondition>
        <simpleAction role='start'/>
      </causalConnector>
      <causalConnector id='c2'>
        <simpleCondition role='onEnd'/>
        <simpleAction role='start'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='b'>
    <port id='start-m1' component='m1'/>
    <port id='start-m3' component='ctx1' interface='port-m3'/>
    <property name='p1' value='1'/>
    <context id='ctx1'>
      <port id='port-m3' component='m3'/>
      <port id='m3-prop' component='m3' interface='background'/>
      <media id='m3' src='media/video3.ogv'>
        <property name='background' value='grey'/>
      </media>
    </context>
    <media id='m1' src='media/video1.ogv'>
      <area id='a1' begin='1s'/>
      <area id='a2' begin='2s' end='3s'/>
      <property name='background' value='grey'/>
    </media>
    <media id='m2'/>
    <link xconnector='c1'>
      <bind role='onEnd' component='m1'/>
      <bind role='start' component='m2'/>
      <bind role='left' component='ctx1' interface='m3-prop'/>
      <bind role='right' component='m1' interface='background'/>
    </link>
    <link xconnector='c2'>
      <bind role='onEnd' component='m2'/>
      <bind role='start' component='ctx1' interface='port-m3'/>
    </link>
  </body>
</ncl>
]]

local ncl = assert(dietncl.parsestring (str))
local ltab = assert(filter.apply (ncl))

local result = {'context', 'b',
              {p1='1'},
              {'m1@lambda', 'm3@lambda'},
              {
                 {'context', 'ctx1',
                  {},
                  {'m3@lambda'},
                  {
                     {'media', 'm3',
                      {src='media/video3.ogv',
                       background='grey'},
                      {}
                     }
                  },
                  {}
                 },
                 {'media', 'm1',
                  {src='media/video1.ogv',
                   background='grey'},
                  {{'a1', '1s'}, {'a2', '2s', '3s'}}},
                 {'media', 'm2', {}, {}},
              },
              {
                 {
                    {
                       {'stop', 'm1@lambda',
                        {'m3.background', '==', 'm1.background'}}
                    },
                    {
                       {'start', 'm2@lambda'}
                    }
                 },
                 {
                    {{'stop', 'm2@lambda', {true}}},
                    {{'start', 'm3@lambda'}}
                 }
              }
}

assert (deepcompare(ltab, result))


--------------------------------------------------

-- Nested compoundStatement with a "set" transition

local str = [[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c1'>
        <compoundCondition operator='and'>
          <simpleCondition role='onEnd'/>
          <compoundStatement operator='and'>
            <assessmentStatement comparator='eq'>
              <attributeAssessment role='left' eventType='attribution'/>
              <attributeAssessment role='right' eventType='attribution'/>
            </assessmentStatement>
            <compoundStatement operator='and'>
              <assessmentStatement comparator='eq'>
                <attributeAssessment role='left' eventType='attribution'/>
                <attributeAssessment role='right' eventType='attribution'/>
              </assessmentStatement>
              <assessmentStatement comparator='eq'>
                <attributeAssessment role='left' eventType='attribution'/>
                <attributeAssessment role='right' eventType='attribution'/>
              </assessmentStatement>
            </compoundStatement>
          </compoundStatement>
        </compoundCondition>
        <simpleAction role='set' value='2'/>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='b'>
    <port id='start-m1' component='m1'/>
    <property name='p1' value='1'/>
    <media id='m1' src='media/video1.ogv'/>
    <media id='m2' src='media/video2.ogv'/>
    <link xconnector='c1'>
      <bind role='onEnd' component='m1'/>
      <bind role='set' component='b' interface='p1'/>
      <bind role='left' component='b' interface='p1'/>
      <bind role='right' component='b' interface='p1'/>
    </link>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local ltab = filter.apply (ncl)
assert(ltab)

local result = {'context', 'b',
                {p1='1'},
                {'m1@lambda'},
                {
                   {'media', 'm1',
                    {src='media/video1.ogv'}, {}},
                   {'media', 'm2',
                    {src='media/video2.ogv'}, {}}
                },
                {
                   {
                      {{'stop', 'm1@lambda',
                        {'and', {'b.p1' , '==', 'b.p1'},
                         {'and', {'b.p1' , '==', 'b.p1'},
                          {'b.p1' , '==', 'b.p1'}}}
                      }},
                      {{'start', 'b.p1', '2'}}
                   }
                }
}

assert (deepcompare(ltab, result))


--------------------------------------------------

-- Doubly nested context

local str = [[
<ncl>
  <head>
  </head>
  <body id='b'>
    <port id='start-m1-b' component='ctx1' interface='start-m1-ctx1'/>
    <context id='ctx1'>
      <port id='start-m1-ctx1' component='ctx2' interface='start-m1-ctx2'/>
      <context id='ctx2'>
        <port id='start-m1-ctx2' component='m1'/>
        <media id='m1' src='media/video1.ogv'/>
      </context>
    </context>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local ltab = filter.apply (ncl)
assert(ltab)

local result = {'context', 'b', {},
                {'m1@lambda'},
                {
                   {'context', 'ctx1', {},
                    {'m1@lambda'},
                    {
                       {'context', 'ctx2', {},
                        {'m1@lambda'},
                        {
                           {'media', 'm1',
                            {src='media/video1.ogv'}, {}}
                        },
                        {}
                       }
                    },
                    {}
                   },
                },
                {}
}

assert (deepcompare(ltab, result))


--------------------------------------------------

-- Link with multiple conditions/actions

local str = [[
<ncl>
  <head>
    <connectorBase>
      <causalConnector id='c1'>
        <compoundCondition operator='and'>
          <simpleCondition role='onEnd-m1' transition='stops' eventType='presentation'/>
          <compoundCondition operator='and'>
            <simpleCondition role='onEnd-m2' transition='stops' eventType='presentation'/>
            <simpleCondition role='onEnd-m3' transition='stops' eventType='presentation'/>
          </compoundCondition>
        </compoundCondition>
        <compoundAction>
          <simpleAction role='start-m4' actionType='start' eventType='presentation'/>
          <compoundAction>
            <simpleAction role='start-m5' actionType='start' eventType='presentation'/>
            <simpleAction role='start-m6' actionType='start' eventType='presentation'/>
          </compoundAction>
        </compoundAction>
      </causalConnector>
    </connectorBase>
  </head>
  <body id='b'>
    <port id='start-m1' component='m1'/>
    <port id='start-m2' component='m2'/>
    <port id='start-m3' component='m3'/>
    <media id='m1' src='media/video1.ogv'/>
    <media id='m2' src='media/video2.ogv'/>
    <media id='m3' src='media/video3.ogv'/>
    <media id='m4' src='media/video4.ogv'/>
    <media id='m5' src='media/video5.ogv'/>
    <media id='m6' src='media/video6.ogv'/>
    <link xconnector='c1'>
      <bind role='onEnd-m1' component='m1'/>
      <bind role='onEnd-m2' component='m2'/>
      <bind role='onEnd-m3' component='m3'/>
      <bind role='start-m4' component='m4'/>
      <bind role='start-m5' component='m5'/>
      <bind role='start-m6' component='m6'/>
    </link>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local ltab = filter.apply (ncl)
assert(ltab)

local result = {'context', 'b',
                {},
                {'m1@lambda', 'm2@lambda', 'm3@lambda'},
                {
                   {'media', 'm1',
                    {src='media/video1.ogv'}, {}},
                   {'media', 'm2',
                    {src='media/video2.ogv'}, {}},
                   {'media', 'm3',
                    {src='media/video3.ogv'}, {}},
                   {'media', 'm4',
                    {src='media/video4.ogv'}, {}},
                   {'media', 'm5',
                    {src='media/video5.ogv'}, {}},
                   {'media', 'm6',
                    {src='media/video6.ogv'}, {}}
                },
                {
                   {
                      {
                         {'stop', 'm1@lambda', {true}},
                         {'stop', 'm2@lambda', {true}},
                         {'stop', 'm3@lambda', {true}}
                      },
                      {
                         {'start', 'm4@lambda'},
                         {'start', 'm5@lambda'},
                         {'start', 'm6@lambda'},
                      }
                   }
                }
}

assert (deepcompare(ltab, result))


--------------------------------------------------

-- TODO:
-- Use a Switch element

local str = [[
<ncl>
  <head>
  </head>
  <body id='b'>
  </body>
</ncl>
]]

local ncl = dietncl.parsestring (str)
local ltab = filter.apply (ncl)
assert(ltab)

local result = {'context', 'b',
                {},
                {},
                {},
                {}
}

assert (deepcompare(ltab, result))
