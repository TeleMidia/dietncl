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

local io     = io
local os     = os
local assert = assert
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
