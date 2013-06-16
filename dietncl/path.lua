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
module (...)

local function at (s, i)
   return s:sub (i,i)
end

-- True if we're on MS Windows.
local is_windows = at (_G.package.config, 1) == '\\'

-- Returns true if char C is a path separator.
local function is_slash (c)
   if is_windows then
      return c == '/' or c == '\\'
   else
      return c == '/'
   end
end

-- Returns the length of file system prefix in path name P.
local function fs_prefix_len (p)
   if is_windows and (at (p, 1)):match ('[a-zA-Z]') and at (p, 2) ':' then
      return 2
   end
   return 0
end


-- Exported functions.

-- Returns true if path name P is absolute.
function is_absolute (p)
   if is_slash (at (p, 1)) then
      return true
   end
   if is_windows and fs_prefix_len (p) > 0 then
      return true
   end
   return false
end

-- Returns true if path name P is relative.
function is_relative (p)
   return not is_absolute (p)
end

-- Returns the dirname and basename parts of path name P.
-- If there is no dirname part, the first returned value will be empty.
function split (p)
   local base = fs_prefix_len (p)
   local i = #p
   while i > base and not is_slash (at (p, i)) do
      i = i - 1
   end
   return p:sub (1, i), p:sub (i + 1)
end

-- Returns the result of concatenating path names P and Q.
function join (p, q)
   if #p == 0 then
      return q
   elseif #q == 0 then
      return p
   else
      return (p..'/'..q):gsub ('/+', '/')
   end
end
