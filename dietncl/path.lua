-- path.lua -- Path manipulation.
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

local _G = _G
local assert = assert
module (...)

-- Returns true if we're on MS Windows.
local function is_windows ()
   return _G.package.config:sub (1,1) == '\\'
end

-- Returns true if char C is a path separator.
local function is_sep (c)
   if is_windows () then
      return c == '/' or c == '\\'
   else
      return c == '/'
   end
end


-- Exported functions.

-- Returns true if path-name P is absolute.
function is_absolute (p)
   local c = p:sub (1,1)
   if is_windows () then
      return c == '/' or c == '\\' or p:sub (2,2) == ':'
   else
      return c == '/'
   end
end

-- Returns true if path-name P is relative.
function is_relative (p)
   return not is_absolute (p)
end

-- Returns the directory part and file part of path-name P.
-- If there is no directory part, the first returned value will be empty.
function split (p)
   local i = #p
   assert (i > 0)
   while i > 0 do
      local c = p:sub (i,i)
      if is_sep (c) then
         break
      end
      i = i - 1
   end
   if i == 0 then
      return '', p
   end
   return p:sub (1, i), p:sub (i+1)
end

-- Returns the directory part of path-name P.
function dirname (p)
   local dir, _ =  split (p)
   return dir
end

-- Returns the file part of path-name P.
function basename (p)
   local _, file = split (p)
   return file
end

-- Returns the result of concatenating path-names P and Q.
function join (p, q)
   assert (#p > 0 or #q > 0)
   if is_sep (p:sub (#p, #p)) or is_sep (q:sub (1,1)) then
      return p..q
   else
      return p..'/'..q
   end
end
