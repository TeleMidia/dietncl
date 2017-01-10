--[[ Copyright (C) 2013-2017 PUC-Rio/Laboratorio TeleMidia

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

local assert = assert
local xml = require ('dietncl.xmlsugar')
_ENV = nil

local root = xml.eval ('<root/>')
local clone = root:clone ()
assert (root ~= clone)
assert (clone:tag () == 'root')
assert (clone:parent () == nil)
assert ( #clone == #root)

local root = xml.eval ("<root a='1' b='2' c='3'/>")
local clone = root:clone ()
assert (root ~= clone)
assert  (clone:tag () == 'root')
assert (#clone == #root)
assert (clone.a == '1')
assert (clone.b == '2')
assert (clone.c == '3')

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
local root = xml.eval (s)
local clone = root:clone ()
assert (root:equal (clone))

local function compar (a, b)
   assert (a ~= b)
   assert (a:tag () == b:tag ())
   if a:parent () == nil then
      assert (b:parent () == nil)
   else
      assert (b:parent () ~= nil)
      assert (a:parent():tag () == b:parent():tag ())
      assert (#(a:parent ()) == #(b:parent ()))
   end
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
