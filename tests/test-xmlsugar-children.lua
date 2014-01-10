-- test-xmlsugar-children.lua -- Checks xmlsugar.children.
-- Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
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

root = xml.new ('root')
for i=1,100 do
   root:insert (xml.new (tostring (i)))
end

i = 0
for e in root:children () do
   i = i + 1
   assert (e:parent () == root)
   assert (e:tag () == tostring (i))
end
assert (i == 100)

-- Remove elements while iterating.
i = 0
for e in root:children () do
   i = i + 1
   root:remove (e)
   assert (#root == 100 - i)
end
assert (i == 100)
assert (#root == 0)
