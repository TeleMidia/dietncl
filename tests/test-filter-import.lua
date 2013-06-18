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


-- TODO: Check multiple inclusions of the same file.


-- Check non-recursive resolution.

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
assert (#ncl:match ('importBase') == 0)

local r1 = assert (ncl:match ('region', 'id', 'x#r1')[1])
assert (r1.left == '13%')

local r2 = assert (ncl:match ('region',  'id', 'x#r2')[1])
assert (r2.top == '25%')

local d1 = assert (ncl:match ('descriptor', 'id', 'y#d1')[1])
assert (d1.transIn == ';')
assert (d1.transOut == 'y#t1;y#t2')
assert (d1[1].name == 'top' and d1[1].value == '30')
assert (d1[2].name == 'left' and d1[2].value == '35%')

local d2 = assert (ncl:match ('descriptor', 'id', 'y#d2')[1])
assert (d2.region == 'y#r2')
assert (d2[1].name == 'right' and d2[1].value == '5')

local d3 = assert (ncl:match ('descriptor', 'id', 'y#d3')[1])
assert (d3.transIn == 'y#t1;y#t2;y#t3;')
assert (d3.transOut == 'y#t1')
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
assert (#ncl:match ('importBase') == 0)

assert (#(ncl:match ('descriptorBase')[1]) == 2)
assert (ncl:match ('descriptor', 'id', 'd2')[1])
local d1 = assert (ncl:match ('descriptor', 'id', 'a#d1')[1])
assert (d1.region == 'a#r2')
assert (d1[1].name == 'top' and d1[1].value == '3.5%')

assert (#(ncl:match ('connectorBase')[1]) == 3)
assert (ncl:match ('causalConnector', 'id', 'c2')[1])
local c1 = assert (ncl:match ('causalConnector', 'id', 'b#x#c1')[1])
assert (c1[1]:tag () == 'simpleCondition' and c1[1].role == 'onBegin')
assert (c1[2]:tag () == 'simpleAction' and c1[2].role == 'start')
c1 = assert (ncl:match ('causalConnector', 'id', 'b#w#c1')[1])
assert (c1[1]:tag () == 'simpleCondition' and c1[1].role == 'onPause')
assert (c1[2]:tag () == 'simpleAction' and c1[2].role == 'abort')

assert (#(ncl:match ('regionBase')[1]) == 2)
local r3 = assert (ncl:match ('region', 'id', 'c#r3')[1])
assert (r3.zIndex == '3')

local r1 = assert (ncl:match ('region', 'id', 'c#y#r1')[1])
assert (r1.top == '34%')
assert (r1[1].id == 'c#y#r2' and r1[1].left == '44%')

os.remove (tmp1)
os.remove (tmp2)
os.remove (tmp3)
