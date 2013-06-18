-- errmsg.lua -- Predefined error messages.
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

local pairs = pairs
module (...)

local messages = {
   attrmissing = "invalid <%s>: missing required attribute '%s'",
   badparent   = "invalid <%s>: bad parent <%s>",
   badidref    = "invalid <%s>: bad id-ref %s='%s'",
}

-- Install exported functions.
for k,v in pairs (messages) do
   _M[k] = function (...)
      return messages[k]:format (...)
   end
end
