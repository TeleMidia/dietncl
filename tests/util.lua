-- util.lua -- Utility functions for tests.
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

local dietncl = require ('dietncl')

local io      = io
local os      = os
local assert  = assert
module (...)

-- Writes the string S into a temporary file and Returns the name of this
-- file.  The caller must use os.remove() to remove the temporary file when
-- is no longer needed.
function tmpfile (s)
   local tmp = os.tmpname ()
   local fp = assert (io.open (tmp, 'w'))
   fp:write (s)
   fp:close ()
   return tmp
end

-- Parses the formatted NCL string FMT and returns the resulting document.
function parsenclformat (fmt, ...)
   return dietncl.parsestring ((fmt):format (...))
end

-- Checks whether tree E1 is equal to tree E2 ignoring element order.
function uequal (e1, e2)
   if e1:tag () ~= e2:tag () then
      return false
   end
   for k,_ in e1:attributes () do
      if e1[k] ~= e2[k] then
         return false
      end
   end
   for k,_ in e2:attributes () do
      if e2[k] ~= e1[k] then
         return false
      end
   end
   if #e1 ~= #e2 then
      return false
   end
   local n = #e1
   if n == 0 then
      return true
   end
   for i=1,n do
      local found = false
      for j=1,n do
         if uequal (e1[i], e2[j]) then
            found = true
            break
         end
      end
      if not found then
         return false
      end
   end
   for i=1,n do
      local found = false
      for j=1,n do
         if uequal (e2[i], e1[j]) then
            found = true
            break
         end
      end
      if not found then
         return false
      end
   end
   return true
end
