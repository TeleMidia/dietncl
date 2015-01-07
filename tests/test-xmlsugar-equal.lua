--[[ Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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

local e1 = xml.eval ('<root/>')
assert (e1:equal (e1))

local e2 = xml.eval ('<root></root>')
assert (e1:equal (e2))

local e2 = xml.eval ('<ROOT/>')
assert (not e1:equal (e2))

local e2 = xml.eval ("<root x='y'/>")
assert (not e1:equal (e2))

local e1 = xml.eval ([[
<root>
 <a x='1'>
  <b y='2'/>
 </a>
 <c z='3'/>
</root>]])

local e2 = xml.eval ([[
<!-- xyz -->
<root>
 <a x='1'>
  <b y='2'>
  </b>
 </a>
 <c z='3'></c>
</root>]])

assert (e1:equal (e2))
e2[1].y = '3'
assert (not e1:equal (e2))
