--[[ filter.transition -- Removes transition elements.
     Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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

-- The TRANSITION filter removes the <transition> and <transitionBase>
-- elements from a given NCL document.  It proceeds by expanding the
-- definition of each transition into the associated <property>,
-- <descriptor>, or <descriptorParam> elements.
--
-- Depends: IMPORT.

local filter = {}

local assert = assert
local ipairs = ipairs
local table  = table

local xml = require ('dietncl.xmlsugar')
local aux = require ('dietncl.nclaux')
_ENV = nil

-- List of non-descriptor attributes that may point to transitions.
local query = {
   { 'descriptorParam', 'name', 'transIn'  },
   { 'descriptorParam', 'name', 'transOut' },
   { 'property',        'name', 'transIn'  },
   { 'property',        'name', 'transOut' },
}

-- Default sub-type for a given transition type.
local default_subtype_list = {
   barWipe            = 'leftToRight',
   boxWipe            = 'topLeft',
   fourBoxWipe        = 'cornersIn',
   barnDoorWipe       = 'vertical',
   diagonalWipe       = 'topLeft',
   bowTieWipe         = 'vertical',
   miscDiagonalWipe   = 'doubleBarnDoor',
   veeWipe            = 'down',
   barnVeeWipe        = 'down',
   zigZagWipe         = 'leftToRight',
   barnZigZagWipe     = 'vertical',
   irisWipe           = 'rectangle',
   triangleWipe       = 'up',
   arrowHeadWipe      = 'up',
   pentagonWipe       = 'up',
   hexagonWipe        = 'horizontal',
   ellipseWipe        = 'circle',
   eyeWipe            = 'horizontal',
   roundRectWipe      = 'horizontal',
   starWipe           = 'fourPoint',
   miscShapeWipe      = 'heart',
   clockWipe          = 'clockwiseTwelve',
   pinWheelWipe       = 'twoBladeVertical',
   singleSweepWipe    = 'clockwiseTop',
   fanWipe            = 'centerTop',
   doubleFanWipe      = 'fanOutVertical',
   doubleSweepWipe    = 'parallelVertical',
   saloonDoorWipe     = 'top',
   windshieldWipe     = 'right',
   snakeWipe          = 'topLeftHorizontal',
   spiralWipe         = 'topLeftClockwise',
   parallelSnakesWipe = 'verticalTopSame',
   boxSnakesWipe      = 'twoBoxTop',
   waterfallWipe      = 'verticalLeft',
   pushWipe           = 'fromLeft',
   slideWipe          = 'fromLeft',
   fade               = 'crossfade',
   audioFade          = 'fade',
   audioVisualFade    = 'crossfade',
}

---
-- Returns the inline definition of transition with XML-ID ID in the given
-- NCL document.
--
local function expand (ncl, id)
   local trans
   trans = ncl:match ('transition', 'id', id)
   assert (trans.type and default_subtype_list[trans.type])
   return ("(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"):format (
      trans.type,
      trans.subtype or default_subtype_list[trans.type],
      trans.dur           or '1s',
      trans.startProgress or '0',
      trans.endProgress   or '1',
      trans.direction     or 'forward',
      trans.fadeColor     or 'black',
      trans.horzRepeat    or '1',
      trans.vertRepeat    or '1',
      trans.borderWidth   or '0',
      trans.borderColor   or 'black')
end

function filter.apply (ncl)
   for desc in ncl:gmatch ('descriptor', '^trans[IO].*$', nil, 2) do
      if desc.transIn then
         aux.insert_descparam (desc, 'transIn', desc.transIn)
      end
      if desc.transOut then
         aux.insert_descparam (desc, 'transOut', desc.transOut)
      end
      desc.transIn = nil
      desc.transOut = nil
   end

   local list = {}
   for _,entry in ipairs (query) do
      local t = {ncl:match (table.unpack (entry))}
      for i=1,#t do
         table.insert (list, t[i])
      end
   end

   for _,e in ipairs (list) do
      local new                 -- new, inline value
      assert (e.value)
      for s in e.value:gmatch ('([^;%s]+)') do
         if not s:match ('^%s*%b()%s*$') then
            s = expand (ncl, s)
         end
         if new == nil then
            new = s
         else
            new = new..';'..s
         end
      end
      e.value = new
   end

   for base in ncl:gmatch ('transitionBase') do
      xml.remove (base:parent (), base)
   end

   return ncl
end

return filter
