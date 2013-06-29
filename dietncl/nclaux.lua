-- nclaux.lua -- Auxiliary functions for manipulating NCL documents.
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

require ('dietncl.xmlsugar')
local xml    = xml
local assert = assert
module (...)


-- Exported functions.

-- Inserts into descriptor DESC a new descriptor parameter with name NAME
-- and value VALUE.  If DESC already contains a parameter with the given
-- name, do nothing.

function insert_descparam (desc, name, value)
   if desc:match ('descriptorParam', 'name', name) then
      return                    -- avoid redefinition
   end
   local param = xml.new ('descriptorParam')
   param.name = name
   param.value = value
   desc:insert (param)
end
