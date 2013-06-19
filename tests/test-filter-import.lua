-- test-filter-import.lua -- Checks filter.import.
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

require ('dietncl')
local errmsg = require ('dietncl.errmsg')
local filter = require ('dietncl.filter.import')
local util   = require ('util')


-- Check invalid <importBase>.

-- Missing 'alias'.
ncl = assert (dietncl.parsestring ([[
<ncl>
 <head>
  <regionBase>
   <importBase documentURI='x' />
  </regionBase>
 </head>
 <body />
</ncl>]]))
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err == errmsg.attrmissing ('importBase', 'alias'))

-- Missing 'documentURI'.
ncl = assert (dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <importBase alias='x' />
  </descriptorBase>
 </head>
 <body />
</ncl>]]))
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err == errmsg.attrmissing ('importBase', 'documentURI'))

-- Missing both 'alias' and 'documentURI'.
ncl = assert (dietncl.parsestring ([[
<ncl>
 <head>
  <descriptorBase>
   <importBase />
  </descriptorBase>
 </head>
 <body />
</ncl>]]))
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err == errmsg.attrmissing ('importBase', 'documentURI')
           or err == errmsg.attrmissing ('importBase', 'alias'))

-- Bad parent.
tmp = util.tmpfile ('<ncl><head /><body /></ncl>')
ncl = assert (dietncl.parsestring (([[
<ncl>
 <importBase alias='x' documentURI='%s' />
</ncl>]]):format (tmp)))
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err == errmsg.badparent ('importBase', 'ncl'))
os.remove (tmp)


-- Check invalid 'documentURI' (file not found).

ncl = assert (dietncl.parsestring ([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='!!!NON_EXISTENT!!!' />
  </connectorBase>
 </head>
 <body />
</ncl>]]))
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err:match ('!!!NON_EXISTENT!!!'))

tmp = util.tmpfile ([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='/!!!NON_EXISTENT!!!' />
  </connectorBase>
 </head>
 <body />
</ncl>]])

ncl = assert (dietncl.parsestring (([[
<ncl>
 <head>
  <regionBase>
   <importBase alias='x' documentURI='%s' />
  </regionbAse>
 </head>
 <body />
</ncl>]]):format (tmp)))
ncl, err = filter.apply (ncl)
assert (ncl == nil)
assert (err:match ('/!!!NON_EXISTENT!!!'))
os.remove (tmp)


-- Check <importBase> with invalid 'region' (no such region)

tmp = util.tmpfile ([[
<ncl>
 <head>
  <regionBase>
   <region id='r1' />
  </regionBase>
 </head>
 <body />
</ncl>]])

ncl = assert (dietncl.parsestring (([[
<ncl>
 <head>
  <regionBase>
   <region id='r2' />
   <importBase alias='a' documentURI='%s' region='r3' />
  </regionBase>
 </head>
 <body />
</ncl>]]):format (tmp)))

ncl, err = filter.apply (ncl)
assert (err == errmsg.badidref ('regionBase', 'region', 'r3'))
os.remove (tmp)


-- Check <importBase> with invalid 'baseId' (no such region-base).

tmp = util.tmpfile ([[
<ncl>
 <head>
  <regionBase id='rb'>
   <region id='r1' />
  </regionBase>
 </head>
 <body />
</ncl>]])

ncl = assert (dietncl.parsestring (([[
<ncl>
 <head>
  <regionBase>
   <importBase alias='a' documentURI='%s' baseId='rb' />
   <importBase alias='b' documentURI='%s' baseId='rbx' />
  </regionBase>
 </head>
 <body />
</ncl>]]):format (tmp, tmp)))

ncl, err = filter.apply (ncl)
assert (err == errmsg.badidref ('regionBase', 'baseId', 'rbx'))
os.remove (tmp)


-- TODO: Check multiple inclusions of the same file.


-- TODO: Check circular inclusions.


-- Check simple (non-recursive) resolution.

tmp = util.tmpfile ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' transIn=';' transOut='t1;  t2'>
    <descriptorParam name='top' value='30' />
    <descriptorParam name='left' value='35%' />
   </descriptor>
   <descriptor id='d2' region='r2'>
    <descriptorParam name='right' value='5' />
   </descriptor>
   <descriptor id='d3' transIn=' t1;t2;t3 ;  ' transOut='t1 ' />
  </descriptorBase>
  <regionBase>
   <region id='r1' left='13%' />
   <region id='r2' top='25%' />
  </regionBase>
  <transitionBase>
  </transitionBase>
 </head>
 <body />
</ncl>]])

ncl = assert (dietncl.parsestring (([[
<ncl>
 <head>
  <regionBase>
   <importBase alias='x' documentURI='%s' />
  </regionBase>
  <descriptorBase>
   <importBase alias='y' documentURI='%s' />
  </descriptorBase>
  <transitionBase>
   <importBase alias='z' documentURI='%s' />
  </transitionBase>
  <connectorBase>
   <importBase alias='w' documentURI='%s' />
  </connectorBase>
 </head>
</ncl>]]):format (tmp, tmp, tmp, tmp)))

ncl = assert (filter.apply (ncl))
assert (ncl:match ('importBase') == nil)

local r1 = assert (ncl:match ('region', 'id', 'x#r1'))
assert (r1.left == '13%')

local r2 = assert (ncl:match ('region',  'id', 'x#r2'))
assert (r2.top == '25%')

local d1 = assert (ncl:match ('descriptor', 'id', 'y#d1'))
assert (d1.transIn == ';')
assert (d1.transOut == 'y#t1;y#t2')
assert (d1[1].name == 'top' and d1[1].value == '30')
assert (d1[2].name == 'left' and d1[2].value == '35%')

local d2 = assert (ncl:match ('descriptor', 'id', 'y#d2'))
assert (d2.region == 'y#r2')
assert (d2[1].name == 'right' and d2[1].value == '5')

local d3 = assert (ncl:match ('descriptor', 'id', 'y#d3'))
assert (d3.transIn == 'y#t1;y#t2;y#t3;')
assert (d3.transOut == 'y#t1')
os.remove (tmp)


-- Check simple resolution of external bases to a given local region.

tmp = util.tmpfile ([[
<ncl>
 <head>
  <regionBase id='rb1' device='3'>
   <region id='rb11' top='30%'>
    <region id='rb12' left='44%' />
   </region>
  </regionBase>
  <regionBase id='rb2'>
   <region id='rb21' width='25%' />
   <region id='rb22' height='23%' />
  </regionBase>
  <regionBase id='rb3'>
   <region id='rb31' zIndex='3' />
   <region id='rb32' zIndex='2'>
    <region id='rb33' />
   </region>
  </regionBase>
 </head>
 <body>
 </body>
</ncl>]])

ncl = dietncl.parsestring (([[
<ncl>
 <head>
  <regionBase id='rba'>
   <importBase alias='a' documentURI='%s' baseId='rb1' />
  </regionBase>
  <regionBase id='rbb'>
   <region id='rbb1' />
   <region id='rbb2'>
    <region id='rbb3' />
   </region>
   <importBase alias='b' documentURI='%s' region='rbb3' baseId='rb3' />
  </regionBase>
 </head>
 <body />
</ncl>]]):format (tmp, tmp))

ncl = assert (filter.apply (ncl))
assert (#{ncl:match ('regionBase')} == 2)

local rb11 = assert (ncl:match ('region', 'id', 'a#rb11'))
assert (rb11.id == 'a#rb11' and rb11.top == '30%')
local rb12 = assert (#rb11 == 1 and rb11[1])
assert (rb12.id == 'a#rb12' and rb12.left == '44%' and #rb12 == 0)

local rbb3 = assert (ncl:match ('region', 'id', 'rbb3'))
assert (rbb3.id == 'rbb3' and #rbb3 == 2)
local rb31 = rbb3[1]
assert (rb31.id == 'b#rb31' and rb31.zIndex == '3' and #rb31 == 0)
local rb32 = rbb3[2]
assert (rb32.id == 'b#rb32' and rb32.zIndex == '2' and #rb32 == 1)
local rb33 = rb32[1]
assert (rb33.id == 'b#rb33' and #rb33 == 0)
os.remove (tmp)


-- Check recursive resolution.

tmp1 = util.tmpfile ([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d1' region='r2'>
    <descriptorParam name='top' value='3.5%' />
   </descriptor>
  </descriptorBase>
  <regionBase>
   <region id='r1' top='34%'>
    <region id='r2' left='44%' />
   </region>
  </regionBase>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onPause' />
    <simpleAction role='abort' />
   </causalConnector>
  </connectorBase>
 </head>
 <body />
</ncl>]])

tmp2 = util.tmpfile ([[
<ncl>
 <head>
  <connectorBase>
   <causalConnector id='c1'>
    <simpleCondition role='onBegin' />
    <simpleAction role='start' />
   </causalConnector>
  </connectorBase>
 </head>
 <body />
</ncl>]])

tmp3 = util.tmpfile (([[
<ncl>
 <head>
  <connectorBase>
   <importBase alias='x' documentURI='%s' />
   <importBase alias='w' documentURI='%s' />
  </connectorBase>
  <regionBase device='7'>
   <region id='r3' zIndex='3' />
   <importBase alias='y' documentURI='%s' />
  </regionBase>
  <descriptorBase>
   <importBase alias='z' documentURI='%s' />
  </descriptorBase>
 </head>
 <body />
</ncl>]]):format (tmp2, tmp1, tmp1, tmp1))

ncl = dietncl.parsestring (([[
<ncl>
 <head>
  <descriptorBase>
   <descriptor id='d2' />
   <importBase alias='a' documentURI='%s' />
  </descriptorBase>
  <connectorBase>
   <causalConnector id='c2'>
    <simpleCondition role='onEnd' />
    <simpleAction role='stop' />
   </causalConnector>
   <importBase alias='b' documentURI='%s' />
  </connectorBase>
  <regionBase>
   <importBase alias='c' documentURI='%s' />
  </regionBase>
 </head>
 <body />
</ncl>]]):format (tmp1, tmp3, tmp3))

ncl = assert (filter.apply (ncl))
assert (ncl:match ('importBase') == nil)

assert (#(ncl:match ('descriptorBase')) == 2)
assert (ncl:match ('descriptor', 'id', 'd2'))
local d1 = assert (ncl:match ('descriptor', 'id', 'a#d1'))
assert (d1.region == 'a#r2')
assert (d1[1].name == 'top' and d1[1].value == '3.5%')

assert (#(ncl:match ('connectorBase')) == 3)
assert (ncl:match ('causalConnector', 'id', 'c2'))
local c1 = assert (ncl:match ('causalConnector', 'id', 'b#x#c1'))
assert (c1[1]:tag () == 'simpleCondition' and c1[1].role == 'onBegin')
assert (c1[2]:tag () == 'simpleAction' and c1[2].role == 'start')
c1 = assert (ncl:match ('causalConnector', 'id', 'b#w#c1'))
assert (c1[1]:tag () == 'simpleCondition' and c1[1].role == 'onPause')
assert (c1[2]:tag () == 'simpleAction' and c1[2].role == 'abort')

assert (#(ncl:match ('regionBase')) == 2)
local r3 = assert (ncl:match ('region', 'id', 'c#r3'))
assert (r3.zIndex == '3')

local r1 = assert (ncl:match ('region', 'id', 'c#y#r1'))
assert (r1.top == '34%')
assert (r1[1].id == 'c#y#r2' and r1[1].left == '44%')

os.remove (tmp1)
os.remove (tmp2)
os.remove (tmp3)
