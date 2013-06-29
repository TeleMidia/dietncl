-- region.lua -- Removes region elements.
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

-- The 'region' filter removes all regions from a given NCL document.  It
-- proceeds by transforming each region into a set of equivalent parameters
-- of the associated descriptors.  This filter depends on the 'import'
-- filter.

require ('dietncl.xmlsugar')
local xml      = xml
local aux      = require ('dietncl.nclaux')
local assert   = assert
local math     = math
local pairs    = pairs
local tonumber = tonumber
module (...)

-- Returns the number value of pixel value S.

function pixeltonumber (s)
   return tonumber (s:match ('^(%d+)$') or s:match ('^(%d+)[Pp][Xx]$'))
end

-- Returns number value of percent value S.

function percenttonumber (s)
   local x = tonumber (s:match ('^(%d*%.?%d*)%%$'))
   if x == nil then
      return nil
   else
      return x / 100
   end
end

-- Some helper functions.

function topercent (n) return (n * 100)..'%' end
function topixel (n) return n..'px' end
function ispixel (s) return pixeltonumber (s) ~= nil end
function ispercent (s) return percenttonumber (s) ~= nil end

-- The following functions (update_*) update the width, height, top, bottom,
-- left, and right attributes of a given region based on the value of the
-- corresponding attributes in the parent region.  These functions implement
-- the following algorithm.
--
--     U (P, R, A) =
--         R[A]           if A=w,h and R[A] is in pixels
--         R[A]*P[A]      if A=w,h and R[A] is in %
--         R[A]+P[A]      if A=t,b,l,r and R[A] and P[A] are in pixels
--         R[A]*P.h+P[A]  if A=t,b and R[A] is in % and
--                          both P.h and P[A] are in % or pixels
--         R[A]*P.w+P[A]  if A=l,r and R[A] is in % and
--                          both P.w and P[A] are in % or pixels
--         undefined      otherwise.
--
-- Here P and R denote regions such that R is an immediate child of P; A
-- denote one of 'width' (w), 'height' (h), 'top' (t), 'bottom' (b), 'left'
-- (l), and 'right' (r); R[A] and P[A] denote the values of A in R and P,
-- respectively; and P.h and P.w denote the width and height of node P.
--
-- The cases where U(P,R,A) is undefined are those where we end up adding a
-- pixel value to a percentage of screen's width or height.  This cannot be
-- done in conversion time because screen dimension is unknown.  The
-- following table summarizes the problematic combinations for A=t,b,l,r.
--
--                  -----------------------------
--                  R[A]  P[A]  P.h/P.w  U(P,R,A)
--                  -----------------------------
--                  px    px    px       px
--                  px    px    %        px
--                  px    %     px       undef.
--                  px    %     %        undef.
--                  %     px    px       px
--                  %     px    %        undef.
--                  %     %     px       undef.
--                  %     %     %        %
--                  -----------------------------

-- Updates width or height attribute ATTR of region REGION based on the
-- value of the corresponding attributes in its parent.
-- Returns true if successful, otherwise returns false plus error message.

local function update_wh (region, attr)
   local parent                 -- pointer to parent
   local regval                 -- value of ATTR in REGION
   local parval                 -- value of ATTR in PARENT

   parent = region:parent ()
   regval = region[attr] or '100%'
   parval = parent[attr]

   assert (ispercent (regval) or ispixel (regval))
   assert (parval == nil or ispercent (parval) or ispixel (parval))

   if parval == nil or ispixel (regval) then
      return true               -- nothing to do
   end

   regval = percenttonumber (regval)
   if ispercent (parval) then
      region[attr] = topercent (regval * percenttonumber (parval))
   else
      region[attr] = topixel (regval * pixeltonumber (parval))
   end
   return true
end

-- Updates top, bottom, left, or right attribute ATTR of region REGION based
-- on the value of the corresponding attributes in the parent region.
-- Returns true if successful, otherwise returns false plus error message.

local function update_tblr_tail (parent, region, attr, dim)
   local regval = region[attr]
   local parval = parent[attr] or '100%'
   local dimval = parent[dim] or '100%'
   local f, g

   if ispercent (parval) and ispercent (dimval) then
      f = percenttonumber
      g = topercent
   elseif ispixel (parval) and ispixel (dimval) then
      f = pixeltonumber
      g = function (n) return topixel (math.floor (n)) end
   else
      return false,
      ("invalid region '%s': unit mismatch in attribute '%s'"):
      format (region.id, attr)
   end

   region[attr] = g (percenttonumber (regval) * f (dimval) + f (parval))
   return true
end

local function update_tblr (region, attr)
   local parent                 -- pointer to parent
   local regval                 -- value of ATTR in REGION
   local parval                 -- value of ATTR in PARENT

   parent = region:parent ()
   regval = region[attr]
   parval = parent[attr]

   if regval == nil then
      region[attr] = parval     -- inherit parent's value
      return true
   end

   if parval == nil then
      return true               -- nothing to do
   end

   assert (ispercent (regval) or ispixel (regval))
   assert (ispercent (parval) or ispixel (parval))

   if ispixel (regval) then
      if ispixel (parval) then
         regval = pixeltonumber (regval)
         parval = pixeltonumber (parval)
         region[attr] = topixel (regval + parval)
         return true
      else
         return false,
         ("invalid region '%s': unit mismatch in attribute '%s'"):
         format (region.id, attr, regval, parent.id, attr, parval)
      end
   end

   if attr == 'top' or attr == 'bottom' then
      return update_tblr_tail (parent, region, attr, 'height')
   elseif attr == 'left' or attr == 'right' then
      return update_tblr_tail (parent, region, attr, 'width')
   else
      error ('unreachable')
   end
end

-- Maps each region attribute to its update function.
local attribute_to_update_function = {
   width  = update_wh,
   height = update_wh,
   top    = update_tblr,
   bottom = update_tblr,
   left   = update_tblr,
   right  = update_tblr,
}

-- Un-nests all regions rooted at parent region REGION.
-- Returns true if successful, otherwise returns false plus error message.

local function unnest (region)
   while #region > 0 do
      local parent              -- pointer to parent
      local child               -- pointer to first child

      parent = region:parent ()
      child = region[1]

      for attr,update in pairs (attribute_to_update_function) do
         if region[attr] == nil and child[attr] == nil then
            goto continue       -- nothing to do
         end
         local status, err = update (child, attr)
         if status == false then
            return false, err
         end
         ::continue::
      end

      region:remove (1)
      parent:insert (child)
      unnest (child)
   end
   return true
end


-- Exported functions.

function apply (ncl)
   for base in ncl:gmatch ('regionBase') do
      for i=1,#base do
         local status, err = unnest (base[i])
         if status == false then
            return nil, err
         end
      end
   end

   for desc in ncl:gmatch ('descriptor', 'region') do
      local region = assert (ncl:match ('region', 'id', desc.region))
      for k,v in region:attributes () do
         if k ~= 'id' then
            aux.insert_descparam (desc, k, v)
         end
      end
      local parent = region:parent ()
      assert (parent:tag () == 'regionBase')
      if parent.device then
         aux.insert_descparam (desc, 'device', parent.device)
      end
      desc.region = nil
   end

   for base in ncl:gmatch ('regionBase') do
      xml.remove (base:parent (), base)
   end

   return ncl
end
