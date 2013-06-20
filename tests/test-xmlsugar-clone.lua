-- test-xmlsugar-clone.lua -- Checks xmlsugar.clone.
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

local root = xml.eval ('<root />')
local clone = root:clone ()
assert (root ~= clone and clone:tag () == 'root' and #clone == #root)

root = xml.eval ("<root a='1' b='2' c='3' />")
clone = root:clone ()
assert (root ~= clone and clone:tag () == 'root' and #clone == #root)
assert (clone.a == '1' and clone.b == '2' and clone.c == '3')

local s = [[
<root>
 <a value='a'/>
 <b>
  <c>
   <x id='x'/>
  </c>
 </b>
 <d>
  <y id='y'>
   <z/>
  </y>
 </d>
</root>]]
root = xml.eval (s)

clone = root:clone ()
assert (root:equal (clone))
local function compar (a, b)
   assert (a ~= b)
   assert (a:tag () == b:tag ())
   assert (#a == #b)
   for k,v in a:attributes () do
      assert (b[k] == v)
   end
   for k,v in b:attributes () do
      assert (a[k] == v)
   end
   for i=1,#a do
      assert (compar (a[i], b[i]))
   end
   for i=1,#b do
      assert (compar (a[i], b[i]))
   end
   return true
end
assert (compar (root, clone))
